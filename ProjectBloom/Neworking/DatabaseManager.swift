//
//  DatabaseManager.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


enum FetchStatus {
    case notStarted
    case fetching
    case success
    case failed (error: Error)
}

@MainActor
class DatabaseManager: ObservableObject {
    @Published private(set) var status: FetchStatus = .notStarted
    @Published private(set) var activeTasksStatus: FetchStatus = .notStarted
    @Published private(set) var completedTasksStatus: FetchStatus = .notStarted
    @Published var userProjects : [Project] = []
    @Published var projectTasks : [ProjectTask] = []
    @Published var completedTasks : [ProjectTask] = []
    
    private var projectsListener: ListenerRegistration?
    private var projectTasksListener: ListenerRegistration?
    private var completedTasksListener: ListenerRegistration?
    
    
    private var database = Firestore.firestore()
    
    
    
    func createNewProject(projectDetails: Project, user: User) async throws {
        do {
            try database.collection(FirebasePaths.projects.rawValue)
                .document(projectDetails.id.description)
                .setData(from: projectDetails)
            
            print("Project \(projectDetails.name) created successfully!")
            
            try await assignDefaultTasks(projectDetails: projectDetails,user: user)
            
        } catch {
            print("Error adding document: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteProject(projectID: String) async throws {
        let projectRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectID)
        
        
        do {
            try await deleteSubCollection(parentRef: projectRef,
                                          subcollectionNames: [FirebasePaths.projectTasks.rawValue,
                                                               FirebasePaths.completedTasks.rawValue])
            try await projectRef.delete()
            print("Project and its subcollections deleted successfully!")
        } catch {
            print("Error deleting project: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func deleteSubCollection(parentRef: DocumentReference,
                                     subcollectionNames: [String]) async throws {
        for subcollection in subcollectionNames {
            let subcollectionRef = parentRef.collection(subcollection)
            let documents = try await subcollectionRef.getDocuments()
            
            let batch = database.batch()
            
            for document in documents.documents {
                batch.deleteDocument(document.reference)
            }
            
            try await batch.commit()
        }
    }
    
    func updateProjectName(projectDetails: Project, newProjectName: String) async throws {
        let taskRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectDetails.id.description)
        
        do {
            try await taskRef.setData([
                "name": newProjectName
            ],merge: true)
            
            print("Project name updated successfully to \(projectDetails.name)")
        } catch {
            print("Error updating project name: \(error.localizedDescription)")
            throw error
        }
    }
    
    func assignDefaultTasks(projectDetails: Project,user: User) async throws {
        let starterprojectTasks = [
            ProjectTask(title: DefaultTaskStrings.defaultTaskTitle.rawValue, assignedToID: user.uid,assignedToUserName: user.displayName ?? "", isActiveTask: false),
            ProjectTask(title: DefaultTaskStrings.defaultTaskTitle.rawValue, assignedToID: user.uid, assignedToUserName: user.displayName ?? "", isActiveTask: false)
        ]
        
        let batch = database.batch()
        
        for task in starterprojectTasks {
            let taskRef = database.collection(FirebasePaths.projects.rawValue)
                .document(projectDetails.id.description)
                .collection(FirebasePaths.projectTasks.rawValue)
                .document(task.id.description)
            batch.setData(try Firestore.Encoder().encode(task), forDocument: taskRef)
        }
        
        try await batch.commit()
    }
    
    func deleteCompletedTask(projectId: String, projectTask: ProjectTask) async throws {
        let taskRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectId)
            .collection(FirebasePaths.completedTasks.rawValue)
            .document(projectTask.id.description)
        
        do {
            try await taskRef.delete()
            print("Task \(projectTask.id.description) successfully deleted")
        } catch {
            print ("Error deleting task: \(error.localizedDescription)")
            throw error
        }
    }
    
    func addTaskBackToCompleted(projectId:String, projectTask: ProjectTask) async throws {
        let taskRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectId)
            .collection(FirebasePaths.completedTasks.rawValue)
            .document(projectTask.id.description)
        
        try taskRef.setData(from: projectTask)
    }
    
    
    func updateTask(projectId: String, projectTask: ProjectTask, newTaskName: String) async throws {
        let taskRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectId)
            .collection(FirebasePaths.projectTasks.rawValue)
            .document(projectTask.id.description)
        
        var updatedTask = projectTask
        
        if(!projectTask.isActiveTask){
            updatedTask.isActiveTask = true
        }
        
        updatedTask.title = newTaskName
        
        try taskRef.setData(from: updatedTask)
        print("Task successfully updated")
    }
    
    func completeTask(projectId: String, projectTask: ProjectTask, userID: String) async throws {
        var completedTask = projectTask
        var updatedTask = projectTask
        completedTask.id = UUID()
        completedTask.completedAt = Timestamp(date: Date())
        completedTask.isActiveTask = false
        updatedTask.title = "No Task Assigned"
        updatedTask.isActiveTask = false
        do {
            try database.collection(FirebasePaths.projects.rawValue)
                .document(projectId)
                .collection(FirebasePaths.completedTasks.rawValue)
                .document(completedTask.id.description)
                .setData(from: completedTask)
            
            try database.collection(FirebasePaths.projects.rawValue)
                .document(projectId)
                .collection(FirebasePaths.projectTasks.rawValue)
                .document(updatedTask.id.description)
                .setData(from: updatedTask)
            
            print("Completed task added for project ID: \(projectId), task ID: \(projectTask.id), completedAt: \(String(describing: completedTask.completedAt))")
            
        } catch {
            print("Error adding completed task: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func listenToProjectTasks(projectID: String, taskType: String) {
        
        updateStatus(for: taskType, status: .fetching)
        
        let listener = database.collection(FirebasePaths.projects.rawValue)
            .document(projectID)
            .collection(taskType)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {return}
                
                if let error = error {
                    updateStatus(for: taskType, status: .failed(error: error))
                    print("Error fetching project tasks: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    updateStatus(for: taskType, status: .failed(error: NSError(domain: "Database Manager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No Tasks Found"])))
                    
                    print("No Tasks Found")
                    return
                }
                
                do {
                    try mapTasks(from: snapshot, to: taskType)
                    updateStatus(for: taskType, status: .success)
                    print("Fetched tasks: \(self.completedTasks)")
                } catch {
                    updateStatus(for: taskType, status: .failed(error: error))
                    print("Error decoding tasks: \(error.localizedDescription)")
                }
            }
        
        if taskType == FirebasePaths.projectTasks.rawValue {
            projectTasksListener = listener
        } else {
            completedTasksListener = listener
        }
    }
    
    private func updateStatus(for taskType: String, status: FetchStatus) {
        if taskType == FirebasePaths.projectTasks.rawValue {
            activeTasksStatus = status
        } else {
            completedTasksStatus = status
        }
    }
    
    private func mapTasks(from snapshot: QuerySnapshot, to taskType: String) throws {
        if taskType == FirebasePaths.projectTasks.rawValue {
            self.projectTasks = try snapshot.documents.map { document in
                return try document.data(as: ProjectTask.self)
                
            }
        } else {
            self.completedTasks = try snapshot.documents.map { document in
                return try document.data(as: ProjectTask.self)
            }
        }
    }
    
    func stopListeningToProjectTasks(taskType: String) {
        if taskType == FirebasePaths.projectTasks.rawValue {
            projectTasksListener?.remove()
            projectTasksListener = nil
            print("Stopped listening to project tasks.")
        } else {
            completedTasksListener?.remove()
            completedTasksListener = nil
            print("Stopped listening to completed tasks.")
        }
    }
    
    func getUserTasks (userID: String) -> [ProjectTask] {
        return projectTasks.filter {
            $0.assignedToID == userID
        }
    }
    
    func listenToUserProjects(user: User) {
        status = .fetching
        let listener = database.collection(FirebasePaths.projects.rawValue)
            .whereField(FirebasePaths.usersID.rawValue, arrayContains: user.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.status = .failed(error: error)
                    print("Error fetching user projects: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.status = .failed(error: NSError(domain: "DatabaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No documents found."]))
                    print("No documents found.")
                    return
                }
                
                self.userProjects = documents.compactMap {document in
                    return try? document.data(as: Project.self)
                }
                
                self.status = .success
                print("User projects successfully fetched.")
            }
        
        projectsListener = listener
    }
    
    func stopListeningToUserProjects() {
        projectsListener?.remove()
        projectsListener = nil
    }
}


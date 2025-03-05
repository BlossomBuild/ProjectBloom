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

class DatabaseManager {
    static let shared = DatabaseManager()
    var database = Firestore.firestore()
    
    
    
    //MARK: Project Functions
    func createNewProject(projectDetails: Project, user: User) async throws {
        do {
            try database.collection(FirebasePaths.projects.rawValue)
                .document(projectDetails.id.description)
                .setData(from: projectDetails)
            
            try await assignDefaultTasks(projectDetails: projectDetails,user: user)
            
            print("Project \(projectDetails.name) created successfully!")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
            throw error
        }
    }
    
    func assignDefaultTasks(projectDetails: Project,user: User) async throws {
        let starterprojectTasks = [
            ProjectTask(
                title: DefaultTaskStrings.defaultTaskTitle.rawValue,
                assignedToID: user.uid,assignedToUserName: user.displayName ?? "",
                isActiveTask: false
            ),
            ProjectTask(
                title: DefaultTaskStrings.defaultTaskTitle.rawValue,
                assignedToID: user.uid, assignedToUserName: user.displayName ?? "",
                isActiveTask: false
            )
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
    
    
    func deleteProject(projectID: String) async throws {
        let projectRef = database.collection(FirebasePaths.projects.rawValue)
            .document(projectID)
        
        do {
            try await deleteSubCollection(
                parentRef: projectRef,
                subcollectionNames: [
                    FirebasePaths.projectTasks.rawValue,
                    FirebasePaths.completedTasks.rawValue
                ]
            )
            try await projectRef.delete()
            print("Project and its subcollections deleted successfully!")
        } catch {
            print("Error deleting project: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func deleteSubCollection(
        parentRef: DocumentReference,
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
    
    
    func listenToUserProjects(user: User) -> (ListenerRegistration? , [Project]?) {
        var fetchedProjects: [Project]? = nil
        var projectsListener: ListenerRegistration? = nil
        
        let listener = database
            .collection(FirebasePaths.projects.rawValue)
            .whereField(FirebasePaths.usersID.rawValue, arrayContains: user.uid)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error fetching user projects: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found.")
                    return
                }
                
                fetchedProjects = documents.compactMap { document in
                    return try? document.data(as: Project.self)
                }
                print("User projects successfully fetched.")
            }
        projectsListener = listener
        return (projectsListener,fetchedProjects)
    }
}







//
//    func deleteCompletedTask(projectId: String, projectTask: ProjectTask) async throws {
//        let taskRef = database.collection(FirebasePaths.projects.rawValue)
//            .document(projectId)
//            .collection(FirebasePaths.completedTasks.rawValue)
//            .document(projectTask.id.description)
//
//        do {
//            try await taskRef.delete()
//            print("Task \(projectTask.id.description) successfully deleted")
//        } catch {
//            print ("Error deleting task: \(error.localizedDescription)")
//            throw error
//        }
//    }
//
//    func addTaskBackToCompleted(projectId:String, projectTask: ProjectTask) async throws {
//        let taskRef = database.collection(FirebasePaths.projects.rawValue)
//            .document(projectId)
//            .collection(FirebasePaths.completedTasks.rawValue)
//            .document(projectTask.id.description)
//
//        try taskRef.setData(from: projectTask)
//    }
//
//
//    func updateTask(projectId: String, projectTask: ProjectTask,
//                    newTaskName: String, fireBasePath: String) async throws {
//        let taskRef = database.collection(FirebasePaths.projects.rawValue)
//            .document(projectId)
//            .collection(fireBasePath)
//            .document(projectTask.id.description)
//
//        var updatedTask = projectTask
//
//        if(!projectTask.isActiveTask){
//            updatedTask.isActiveTask = true
//        }
//
//        updatedTask.title = newTaskName
//
//        try taskRef.setData(from: updatedTask)
//        print("Task successfully updated")
//    }
//
//    func completeTask(projectId: String, projectTask: ProjectTask, userID: String) async throws {
//        var completedTask = projectTask
//        var updatedTask = projectTask
//        completedTask.id = UUID()
//        completedTask.completedAt = Timestamp(date: Date())
//        completedTask.isActiveTask = false
//        updatedTask.title = "No Task Assigned"
//        updatedTask.isActiveTask = false
//        do {
//            try database.collection(FirebasePaths.projects.rawValue)
//                .document(projectId)
//                .collection(FirebasePaths.completedTasks.rawValue)
//                .document(completedTask.id.description)
//                .setData(from: completedTask)
//
//            try database.collection(FirebasePaths.projects.rawValue)
//                .document(projectId)
//                .collection(FirebasePaths.projectTasks.rawValue)
//                .document(updatedTask.id.description)
//                .setData(from: updatedTask)
//
//            print("Completed task added for project ID: \(projectId), task ID: \(projectTask.id), completedAt: \(String(describing: completedTask.completedAt))")
//
//        } catch {
//            print("Error adding completed task: \(error.localizedDescription)")
//            throw error
//        }
//    }
//
//
//    func listenToProjectTasks(projectID: String, taskType: String) {
//
//
//        let listener = database.collection(FirebasePaths.projects.rawValue)
//            .document(projectID)
//            .collection(taskType)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else {return}
//
//                if let error = error {
//                    print("Error fetching project tasks: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let snapshot = snapshot else {
//
//
//                    print("No Tasks Found")
//                    return
//                }
//            }
//    }




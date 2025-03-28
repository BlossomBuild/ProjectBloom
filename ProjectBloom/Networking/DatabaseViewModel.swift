//
//  DatabaseViewModel.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 3/3/25.
//

import Foundation
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@Observable
class DatabaseViewModel {
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(underlyingError: Error)
    }
    
    enum OperationStatus {
        case notStarted
        case inProgress
        case success
        case failed
    }
    
    private(set) var userProjectsStatus: FetchStatus = .notStarted
    private(set) var userActiveTasksStatus: FetchStatus = .notStarted
    private(set) var userCompletedTasksStatus: FetchStatus = .notStarted
    
    private(set) var projectDeletedStatus: OperationStatus = .notStarted
    
    private var projectsListener: ListenerRegistration?
    private var activeTasksListener: ListenerRegistration?
    private var completedTasksListener: ListenerRegistration?
    
    var userProjects : [Project] = []
    var projectTasks : [ProjectTask] = []
    var completedTasks : [ProjectTask] = []
    
    // MARK: Project Functions
    func createNewProject(projectDetails: Project, user: User) async throws {
        try await DatabaseManager.shared.createNewProject(projectDetails: projectDetails, user: user)
    }
    
    func deleteProject(projectID: String) async throws {
        projectDeletedStatus = .inProgress
        do {
            try await DatabaseManager.shared.deleteProject(projectID: projectID)
            projectDeletedStatus = .success
        } catch {
            projectDeletedStatus = .failed
            try await Task.sleep(nanoseconds: 2_000_000_000)
            projectDeletedStatus = .notStarted
        }
    }
    
    func updateProjectName(project: Project, newProjectName: String) async throws {
        try await DatabaseManager.shared.updateProjectName(
            projectDetails: project,
            newProjectName: newProjectName
            
        )}
    
    func listenToUserProjects(user: User) {
        guard projectsListener == nil else { return}
        
        userProjectsStatus = .fetching
        projectsListener = Firestore.firestore()
            .collection(FirebasePaths.projects.rawValue)
            .whereField(FirebasePaths.usersID.rawValue, arrayContains: user.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.userProjectsStatus = .failed(underlyingError: error)
                    print("Error fetching user projects: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.userProjectsStatus = .failed(underlyingError: NSError(
                        domain: "DatabaseManager",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No documents found."]
                    ))
                    return
                }
                
                self.userProjects = documents.compactMap {document in
                    return try? document.data(as: Project.self)
                }
                
                self.userProjectsStatus = .success
                print("User projects successfully fetched.")
            }
    }
    
    func stopListeningToUserProjects() {
        projectsListener?.remove()
        projectsListener = nil
        print("Stopped listening to user projects")
    }
    
    
    //MARK: Tasks Functions
    func listenToProjectTasks(projectID: String, taskType: String) {
        updateTaskStatus(for: taskType, status: .fetching)
        let listener = Firestore.firestore()
            .collection(FirebasePaths.projects.rawValue)
            .document(projectID)
            .collection(taskType)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {return}
                
                if let error = error {
                    updateTaskStatus(for: taskType,
                                     status: .failed(underlyingError: error))
                    print("Error fetching project tasks: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    updateTaskStatus(for: taskType, status: .failed(underlyingError: NSError(
                        domain: "DatabaseViewModel",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No Tasks Found"]
                    )))
                    print("No Tasks Found")
                    return
                }
                
                do {
                    try mapTasks(from: snapshot, to: taskType)
                    updateTaskStatus(for: taskType, status: .success)
                    print("Fetched Tasks: \(self.projectTasks)")
                } catch {
                    updateTaskStatus(for: taskType, status: .failed(underlyingError: error))
                    print("Error decoding tasks: \(error.localizedDescription)")
                }
            }
        
        if taskType == FirebasePaths.projectTasks.rawValue {
            activeTasksListener = listener
        } else {
            completedTasksListener = listener
        }
    }
    
    func stopListeningToProjectTasks(taskType: String) {
        if taskType == FirebasePaths.projects.rawValue {
            activeTasksListener?.remove()
            activeTasksListener = nil
            print("Stopped listening to active tasks")
        } else {
            completedTasksListener?.remove()
            completedTasksListener = nil
            print("Stopped listening to completed tasks")
        }
    }
    
    private func updateTaskStatus(for taskType: String, status: FetchStatus) {
        if taskType == FirebasePaths.projectTasks.rawValue {
            userActiveTasksStatus = status
        } else {
            userCompletedTasksStatus = status
        }
    }
    
    private func mapTasks(from snapshot: QuerySnapshot, to taskType:String) throws {
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
    
    func getUserTasks (userID: String) -> [ProjectTask] {
        return projectTasks.filter {
            $0.assignedToID == userID
        }
    }
}

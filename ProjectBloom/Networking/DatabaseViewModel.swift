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
        case failed (underlyingError: Error)
    }
    
    enum OperationStatus {
        case notStarted
        case inProgress
        case success
        case failed (underlyingError: Error)
    }
    
    private(set) var userProjectsStatus: FetchStatus = .notStarted
    private(set) var activeTasksStatus: FetchStatus = .notStarted
    private(set) var completedTasksStatus: FetchStatus = .notStarted
    
    private(set) var projectUpdateStatus: OperationStatus = .notStarted
    private(set) var projectDeletedStatus: OperationStatus = .notStarted
    
    private var projectsListener: ListenerRegistration?
    private var projectTasksListener: ListenerRegistration?
    private var completedTasksListener: ListenerRegistration?
    
    var userProjects : [Project] = []
    var projectTasks : [ProjectTask] = []
    var completedTasks : [ProjectTask] = []
    
    // MARK: Project Functions
    func createNewProject(projectDetails: Project, user: User) async throws {
        projectUpdateStatus = .inProgress
        do {
            try await DatabaseManager.shared.createNewProject(projectDetails: projectDetails, user: user)
            projectUpdateStatus = .success
        } catch {
            projectUpdateStatus = .failed(underlyingError: error)
        }
    }
    
    func deleteProject(projectID: String) async throws {
        projectDeletedStatus = .inProgress
        do {
            try await DatabaseManager.shared.deleteProject(projectID: projectID)
            projectDeletedStatus = .success
            
            try await Task.sleep(nanoseconds: 2_000_000_000)
            projectDeletedStatus = .notStarted
        } catch {
            projectDeletedStatus = .failed(underlyingError: error)
        }
    }
    
    func updateProjectName(project: Project, newProjectName: String) async throws {
        projectUpdateStatus = .inProgress
        do {
            try await DatabaseManager.shared.updateProjectName(
                projectDetails: project,
                newProjectName: newProjectName
            )
            projectUpdateStatus = .success
        } catch {
            projectUpdateStatus = .failed(underlyingError: error)
        }
    }
    
    func listenToUserProjects(user: User) {
        userProjectsStatus = .fetching
        let listener = Firestore.firestore()
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
                    
                    print("No documents found.")
                    return
                }
                
                self.userProjects = documents.compactMap {document in
                    return try? document.data(as: Project.self)
                }
                
                self.userProjectsStatus = .success
                print("User projects successfully fetched.")
            }
        
        projectsListener = listener
    }
    
    func stopListeningToUserProjects() {
        projectsListener?.remove()
        projectsListener = nil
     }
}

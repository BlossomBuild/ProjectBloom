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
        projectUpdateStatus = .inProgress
        do {
            try await DatabaseManager.shared.deleteProject(projectID: projectID)
            projectUpdateStatus = .success
        } catch {
            projectUpdateStatus = .failed(underlyingError: error)
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
        
        let(listener,fetchedProjects) = DatabaseManager.shared.listenToUserProjects(user: user)
        
        self.projectsListener = listener
        if let projects = fetchedProjects {
            self.userProjects = projects
            self.userProjectsStatus = .success
        } else {
            self.userProjectsStatus = .failed(
                underlyingError: NSError(
                    domain: "DatabaseViewModel",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: Constants.noProjectsFoundString]
                ))
        }
    }
    
    func stopListeningToUserProjects() {
        projectsListener?.remove()
        projectsListener = nil
     }
}

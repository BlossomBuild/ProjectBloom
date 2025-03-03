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
        case creating
        case success
        case failed (underlyingError: Error)
    }
    
    private(set) var activeProjectsStatus: FetchStatus = .notStarted
    private(set) var activeTasksStatus: FetchStatus = .notStarted
    private(set) var completedTasksStatus: FetchStatus = .notStarted
    
    private(set) var createProjectStatus: OperationStatus = .notStarted
    
    private var projectsListener: ListenerRegistration?
    private var projectTasksListener: ListenerRegistration?
    private var completedTasksListener: ListenerRegistration?
    
    var userProjects : [Project] = []
    var projectTasks : [ProjectTask] = []
    var completedTasks : [ProjectTask] = []
    
    // MARK: Project Functions
    func createNewProject(projectDetails: Project, user: User) async {
        createProjectStatus = .creating
        
        do {
            try await DatabaseManager.shared.createNewProject(projectDetails: projectDetails, user: user)
            createProjectStatus = .success
        } catch {
            createProjectStatus = .failed(underlyingError: error)
        }
    }
}

//
//  DatabaseViewModel.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 3/3/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@Observable
class DatabaseViewModel {
    
    enum OperationStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    
    private(set) var userProjectsStatus: OperationStatus = .notStarted
    private(set) var userActiveTasksStatus: OperationStatus = .notStarted
    private(set) var userCompletedTasksStatus: OperationStatus = .notStarted
    private(set) var userSearchStatus: OperationStatus = .notStarted
    
    private(set) var projectDeletedStatus: OperationStatus = .notStarted
    private(set) var userRemovedStatus: OperationStatus = .notStarted
    
    private var projectsListener: ListenerRegistration?
    private var activeTasksListener: ListenerRegistration?
    private var completedTasksListener: ListenerRegistration?
    private var projectUsersListener: ListenerRegistration?
    
    
    var userProjects : [Project] = []
    var projectTasks : [ProjectTask] = []
    var completedTasks : [ProjectTask] = []
    var sortedCompletedTasks: [ProjectTask] {
        completedTasks.sorted {
            $0.completedAt?.dateValue() ?? Date() >
            $1.completedAt?.dateValue() ?? Date()
        }
    }
    var userDetailsSearch : [UserDetails] = []
    var projectUsers: [UserDetails] = []
    
    
    // MARK: Project Functions
    func deleteProject(projectID: String) async throws {
        projectDeletedStatus = .fetching
        do {
            try await DatabaseManager.shared.deleteProject(projectID: projectID)
            projectDeletedStatus = .success
        } catch {
            projectDeletedStatus = .failed
            try await Task.sleep(nanoseconds: 2_000_000_000)
            projectDeletedStatus = .notStarted
        }
    }
    
    func listenToUserProjects(user: User) {
        guard projectsListener == nil else { return}
        
        userProjectsStatus = .fetching
        projectsListener = Firestore.firestore()
            .collection(FirebasePaths.projects.rawValue)
            .whereField(FirebasePaths.userEmails.rawValue, arrayContains: user.email ?? "")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.userProjectsStatus = .failed
                    print("Error fetching user projects: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.userProjectsStatus = .failed
                    print("Error fetching user projects: No documents found.")
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
                    updateTaskStatus(for: taskType,status: .failed)
                    print("Error fetching project tasks: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    updateTaskStatus(for: taskType, status: .failed)
                    print("No Tasks Found")
                    return
                }
                
                do {
                    try mapTasks(from: snapshot, to: taskType)
                    updateTaskStatus(for: taskType, status: .success)
                    print("Fetched Tasks: \(self.projectTasks)")
                } catch {
                    updateTaskStatus(for: taskType, status: .failed)
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
        if taskType == FirebasePaths.projectTasks.rawValue {
            activeTasksListener?.remove()
            activeTasksListener = nil
            print("Stopped listening to active tasks")
        } else {
            completedTasksListener?.remove()
            completedTasksListener = nil
            print("Stopped listening to completed tasks")
        }
    }
    
    private func updateTaskStatus(for taskType: String, status: OperationStatus) {
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
    
    func sortCompletedTasks() {
        completedTasks.sort(by: {
            $0.completedAt?.dateValue() ?? Date()
            > $1.completedAt?.dateValue() ?? Date()
        })
    }
    
    // MARK: Sharing Functions
    func searchUsersByEmail(project: Project,userEmail: String) async {
        userSearchStatus = .fetching
        do {
            userDetailsSearch = try await DatabaseManager.shared.searchUsersByEmail(project: project, with: userEmail)
            userSearchStatus = .success
        } catch {
            userSearchStatus = .failed
        }
    }
    
    func appendUserEmailToProject(email: String, toProjectID id: UUID) {
        if let index = userProjects.firstIndex(where: { $0.id == id }) {
            if !userProjects[index].userEmails.contains(email) {
                userProjects[index].userEmails.append(email)
                print("Appended \(email) to project ID \(id)")
            } else {
                print("Email \(email) already exists in project")
            }
        } else {
            print("Could not find project with ID \(id)")
        }
    }
    
    func listenToProjectUsers(projectID: String) {
        let listener = Firestore.firestore()
            .collection(FirebasePaths.projects.rawValue)
            .document(projectID)
            .collection(FirebasePaths.userDetails.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {return}
                
                if let error = error {
                    print("Error fetching project users: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No project users found")
                    return
                }
                
                do {
                    self.projectUsers = try snapshot.documents.map { document in
                        return try document.data(as: UserDetails.self)
                    }
                    
                    print("Fetched Project Users: \(self.projectUsers)")
                    
                } catch {
                    
                    print("Error decoding users: \(error.localizedDescription)")
                }
            }
        projectUsersListener = listener
    }
    
    func stopListeningToProjectUsers() {
        projectUsersListener?.remove()
        projectUsersListener = nil
        print("Stopped listening to project users")
    }
    
    func removeUserFromProject(project: Project, userDetails: UserDetails) async throws {
        userRemovedStatus = .fetching
        
        do {
            try await DatabaseManager.shared.removeUserFromProject(
                project: project,
                userDetails: userDetails
            )
            
            removeUserEmailFromProject(email: userDetails.userEmail, fromProjectID: project.id)
            userRemovedStatus = .success
        } catch {
            userRemovedStatus = .failed
            try await Task.sleep(nanoseconds: 2_000_000_000)
            userRemovedStatus = .notStarted
        }
    }
    
    func removeUserEmailFromProject(email: String, fromProjectID id: UUID) {
        if let index = userProjects.firstIndex(where: { $0.id == id }) {
            if let emailIndex = userProjects[index].userEmails.firstIndex(of: email) {
                userProjects[index].userEmails.remove(at: emailIndex)
                print("Removed \(email) from project ID \(id)")
            } else {
                print("Email \(email) not found in project")
            }
        } else {
            print("Could not find project with ID \(id)")
        }
    }
}

//
//  ProjectDetailView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/10/24.
//

import SwiftUI

struct ProjectDetailView: View {
    
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @State private var showUserSearchScreen = false
    
    var project: Project
    
    var body: some View {
        NavigationStack {
            switch databaseViewModel.userActiveTasksStatus {
            case .notStarted:
                EmptyView()
            case .fetching:
                ProgressView()
            case .success:
                TabView {
                    Tab(Constants.activeTasksString, systemImage: Constants.activeTaskIcon) {
                        ScrollView {
                            ForEach(databaseViewModel.projectUsers) { user in
                                UserTasksView(userDetails: user,
                                              projectTasks: databaseViewModel.getUserTasks(userID: user.id),
                                              projectId: project.id.description)
                            }
                        } 
                    }
                    
                    Tab(Constants.completedTasksString, systemImage: Constants.completeTaskIcon) {
                        UserCompletedTaskView(project: project)
                    }
                }
                
            case .failed:
                Text(UserErrorMessages.genericErrorMessage.rawValue)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showUserSearchScreen.toggle()
                } label: {
                    Image(systemName: Constants.addUser)
                        .tint(.bbWhite)
                }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showUserSearchScreen, content: {
            UserSearchScreen(currenProject: project)
        })
        .task {
            databaseViewModel.listenToProjectTasks(
                projectID: project.id.description,
                taskType: FirebasePaths.projectTasks.rawValue
            )
            
            databaseViewModel.listenToProjectUsers(
                projectID: project.id.description
            )
        }
        .onDisappear {
            databaseViewModel.stopListeningToProjectTasks(
                taskType: FirebasePaths.projectTasks.rawValue
            )
            
            databaseViewModel.stopListeningToProjectUsers()
        }
    }
}

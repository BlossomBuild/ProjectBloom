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
                    Tab(UIStrings.activeTasks.localizedKey, systemImage: Constants.activeTaskIcon) {
                        ScrollView {
                            ForEach(databaseViewModel.projectUsers) { user in
                                UserTasksView(userDetails: user,
                                              projectTasks: databaseViewModel.getUserTasks(userID: user.id),
                                              project: project)
                            }
                        }
                    }
                    
                    Tab(UIStrings.completedTasks.localizedKey, systemImage: Constants.completeTaskIcon) {
                        UserCompletedTaskView(project: project)
                    }
                }
                
            case .failed:
                Text(UIStrings.genericErrorMessage.localizedKey)
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
        .overlay {
            Group {
                
                if databaseViewModel.userRemovedStatus == .fetching {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea() // dim background
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
                
                if databaseViewModel.userRemovedStatus == .failed {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        Text(UIStrings.removeUserError.localizedKey)
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                    }
                }
            }
        }
    }
}

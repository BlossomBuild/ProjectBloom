//
//  ProjectDetailView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/10/24.
//

import SwiftUI

struct ProjectDetailView: View {
    
    @Environment(DatabaseViewModel.self) var databaseViewModel
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
                            ForEach(project.usersDetails) { user in
                                UserTasksView(userDetails: user,
                                              projectTasks: databaseViewModel.getUserTasks(userID: user.id),
                                              projectId: project.id.description)
                            }
                        }
                        
                    }
                    
                    Tab(Constants.completedTasksString, systemImage: Constants.completeTaskIcon) {
                        
                    }
                }
                
            case .failed(let error):
                Text("Error: \(error.localizedDescription)")
            }
            
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            databaseViewModel.listenToProjectTasks(projectID: project.id.description, taskType: FirebasePaths.projectTasks.rawValue)
        }
        .onDisappear {
            databaseViewModel.stopListeningToProjectTasks(taskType: FirebasePaths.projectTasks.rawValue)
        }
    }
    
}




#Preview {
    ProjectDetailView(project: Project.sampleProjects[0])
        .environment(DatabaseViewModel())
}

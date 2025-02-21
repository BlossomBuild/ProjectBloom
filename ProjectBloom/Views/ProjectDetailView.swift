//
//  ProjectDetailView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/10/24.
//

import SwiftUI


struct ProjectDetailView: View {
    
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var editProjectName: Bool = false
    
    var project: Project
    
    var body: some View {
        NavigationStack {
            switch databaseManager.activeTasksStatus {
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
                                              projectTasks: databaseManager.getUserTasks(userID: user.id),
                                              projectId: project.id.description)
                            }
                        }
                    }
                    
                    Tab(Constants.completedTasksString,systemImage: Constants.completeTaskIcon){
                        
                            CompletedTasksView(project: project)

                        
                        
                    }
                    
                }
                .navigationTitle(project.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editProjectName.toggle()
                        } label: {
                            Image(systemName: Constants.editIcon)
                                .tint(.bbWhite)
                        }
                    }
                    
                    
                }
                
                .sheet(isPresented: $editProjectName) {
                    EditProjectView(updateProject: true, project: project)
                        .presentationDetents([.fraction(0.25)])
                }
                
                
            case .failed(let error):
                Text("Error: \(error)")
            }
        }
        .task {
            databaseManager.listenToProjectTasks(projectID: project.id.description, taskType: FirebasePaths.projectTasks.rawValue)
        }
        .onDisappear {
            databaseManager.stopListeningToProjectTasks(taskType: FirebasePaths.projectTasks.rawValue)
        }
    }
}


#Preview {
    ProjectDetailView(project: Project.sampleProjects[0])
        .environmentObject(DatabaseManager())
}

//
//  ProjectDetailView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/10/24.
//

import SwiftUI


struct ProjectDetailView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var showCompletedTasks: Bool = false
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
                
                    ScrollView {
                        LazyVStack {
                            ForEach(project.usersDetails) { user in
                                UserTasksView(userDetails: user, projectTasks: databaseManager.getUserTasks(userID: user.id),projectId: project.id.description)
                            }
                            
                            .navigationTitle(project.name)
//                            .navigationTitle("Project")
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
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        showCompletedTasks.toggle()
                                    } label: {
                                        Image(systemName: Constants.clipboardIcon)
                                            .tint(.bbWhite)
                                    }
                                }
                                
                            }
                            .sheet(isPresented: $showCompletedTasks) {
                                CompletedTasksView(project: project)
                            }
                            .sheet(isPresented: $editProjectName) {
                                ProjectEditorView(updateProject: true, project: project)
                                    .presentationDetents([.fraction(0.25)])
                            }
                        }
                    }
                    
                    
                
                
            case .failed(let error):
                Text("Error: \(error)")
            }
        }
        .task{
            databaseManager.listenToProjectTasks(projectID: project.id.description, taskType: FirebasePaths.projectTasks.rawValue)
            }
        }
    }


#Preview {
    ProjectDetailView(project: Project.sampleProjects[0])
        .environmentObject(AuthManager())
        .environmentObject(DatabaseManager())
}

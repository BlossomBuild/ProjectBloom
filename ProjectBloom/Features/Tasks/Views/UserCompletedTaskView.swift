//
//  CompletedTasksView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 1/7/25.
//

import SwiftUI

struct UserCompletedTaskView: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @State private var taskToEdit: ProjectTask?
    @State private var taskToDelete: ProjectTask?
    @State private var showDeleteAlert: Bool = false
    
    var project: Project
    
    
    var body: some View {
        GeometryReader { geo in
            switch databaseViewModel.userCompletedTasksStatus {
            case .notStarted:
                EmptyView()
                
            case .fetching:
                ProgressView()
                    .frame(width: geo.size.width, height: geo.size.height)
                
            case .success:
                if databaseViewModel.completedTasks.isEmpty {
                    Text(UIStrings.noCompletedTasks.localizedKey)
                        .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    List(databaseViewModel.sortedCompletedTasks) {projectTask in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(projectTask.title)
                                .font(.system(size: 13))
                                .bold()
                            
                            Group {
                                Text(UIStrings.completedBy.localizedKey) +
                                Text(Punctuation.colon.localizedKey) +
                                Text(Punctuation.space.localizedKey) +
                                Text(projectTask.assignedToUserName)
                                
                                Text(Constants.getFormattedDate(projectTask: projectTask))
                                 
                            }
                            .font(.system(size: 12))
                            
                        }
                        .onTapGesture {
                            taskToEdit = projectTask
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                taskToDelete = projectTask
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: Constants.trashIcon)
                            }
                        }
                        .tint(.red)
                    }
                    .sheet(item: $taskToEdit) {task in
                        EditTaskView(project: project, projectTask: task)
                            .presentationDetents([.fraction(0.30)])
                    }
                    
                    if let projectTask = taskToDelete {
                        DeleteCompletedTaskAlertView(isPresented: $showDeleteAlert,
                                                     completedTaskToDelete: projectTask,
                                                     projectId: project.id.description)
                    }
                   
                }
                
            case .failed:
                Text(UIStrings.genericErrorMessage.localizedKey)
            }
        }
        .task {
            databaseViewModel.listenToProjectTasks(
                projectID: project.id.description,
                taskType: FirebasePaths.completedTasks.rawValue
            )
        }
        .onDisappear {
            databaseViewModel.stopListeningToProjectTasks(
                taskType: FirebasePaths.completedTasks.rawValue
            )
        }
    }
}

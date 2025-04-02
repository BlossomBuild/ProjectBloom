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
                    Text(Constants.noCompletedTasks)
                        .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    List(databaseViewModel.sortedCompletedTasks) {projectTask in
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(projectTask.title)
                                .font(.system(size: 13))
                                .bold()
                            
                            Text(Constants.completedByString +
                                 Constants.colonString +
                                 Constants.spaceString + projectTask.assignedToUserName)
                            .font(.system(size: 12))
                            
                            Text(Constants.getFormattedDate(projectTask: projectTask))
                                .font(.system(size: 12))
                            
                        }
                    }
                }
                
            case .failed(let error):
                Text(error.localizedDescription)
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

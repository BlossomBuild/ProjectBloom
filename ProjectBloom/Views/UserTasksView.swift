//
//  UserTasksView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/11/24.
//

import SwiftUI

struct UserTasksView: View {
    
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(DatabaseViewModel.self) var databaseViewModel
    
    @State private var showEditTaskSheet: Bool = false
    @State private var taskToEdit: ProjectTask?
    
    
    var userDetails: UserDetails
    var projectTasks: [ProjectTask]
    var project: Project
    
    var shouldShowRemoveIcon: Bool {
        let isLeader = Constants.isProjectLeader(
            leaderID: project.projectLeaderID,
            currentUserID: authViewModel.userDetails?.id ?? ""
        )
        
        let isNotViewingSelf = userDetails.id != authViewModel.userDetails?.id
        
        return isLeader && isNotViewingSelf
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(userDetails.userName)
                        .font(.title3)
                    
                    if(shouldShowRemoveIcon) {
                        Button {
                            
                        } label: {
                            Image(systemName: Constants.removeUserIcon)
                        }
                    }
                }
                
                List(projectTasks){ projectTask in
                    Button {
                        showEditTaskSheet.toggle()
                        taskToEdit = projectTask
                    } label: {
                        Text(projectTask.title)
                    }
                }
                .padding(.top, -25)
                .clipShape(.rect(cornerRadius: 10))
                .sheet(item: $taskToEdit) { task in
                    EditTaskView(project: project, projectTask: task)
                        .presentationDetents([.fraction(0.30)])
                    
                }
                
            }
            .frame(height: 155)
            .padding()
        }
    }
}


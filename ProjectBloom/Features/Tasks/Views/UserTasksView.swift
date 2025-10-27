//
//  UserTasksView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/11/24.
//

import SwiftUI

struct UserTasksView: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var showRemoveUserAlert: Bool = false
    @State private var taskToEdit: ProjectTask?
    @State private var userToRemove: UserDetails?
    
    
    var userDetails: UserDetails
    var projectTasks: [ProjectTask]
    var project: Project
    
    var shouldShowRemoveIcon: Bool {
        let isLeader = Constants.isProjectLeader(
            leaderID: project.projectLeaderID,
            currentUserID: authManager.userDetails?.id ?? ""
        )
        
        let isNotViewingSelf = userDetails.id != authManager.userDetails?.id
        
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
                            showRemoveUserAlert = true
                            userToRemove = userDetails
                        } label: {
                            Image(systemName: Constants.removeUserIcon)
                        }
                    }
                }
                
                List(projectTasks){ projectTask in
                    Button {
                        taskToEdit = projectTask
                    } label: {
                        Text(projectTask.title)
                    }
                }
                .padding(.top, -25)
                .clipShape(.rect(cornerRadius: 10))
                .sheet(item: $taskToEdit) { task in
                    EditTaskView(project: project, projectTask: task)
                        .presentationDetents([.fraction(0.50)])
                }
                
                if let userDetails = userToRemove {
                    RemoveUserAlertView(
                        isPresented: $showRemoveUserAlert,
                        currentProject: project,
                        userToRemove: userDetails
                    )
                }
                
            }
            .frame(height: 155)
            .padding()
        }
    }
}


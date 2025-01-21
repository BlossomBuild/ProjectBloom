//
//  UserTasksView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/11/24.
//

import SwiftUI

struct UserTasksView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var taskToEdit: ProjectTask? = nil
    @State private var tasktoComplete: ProjectTask? = nil
    @State var editProjectTask: Bool =  false
    
    var userDetails: UserDetails
    var projectTasks: [ProjectTask]
    var projectId: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(userDetails.userName)
                .font(.title3)
            
            List(projectTasks){projectTask in
                HStack {
                    Text(projectTask.title)
                   
                                      
                    Spacer()
                    
                    Button {
                        taskToEdit = projectTask
                    } label: {
                        Image(systemName: Constants.editIcon)
                            .foregroundStyle(.buttonText)
                            .padding(.trailing, 8)
                    }
                    .buttonStyle(.plain)
                    
                    if(projectTask.isActiveTask) {
                        Button {
                            tasktoComplete = projectTask
                        } label: {
                            Image(systemName: Constants.checkmarkIcon)
                                .foregroundStyle(.buttonText)
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .sheet(item: $taskToEdit) { task in
                EditTaskView(projectId: projectId ,projectTask: task, editTask: true)
                    .presentationDetents([.fraction(0.25)])
            }
            .sheet(item: $tasktoComplete) { task in
                EditTaskView(projectId: projectId, projectTask: task, editTask: false)
                    .presentationDetents([.fraction(0.25)])
            }
            
        }
        .frame(height: 225)
        .padding()
    }
}


#Preview {
    UserTasksView(userDetails: UserDetails.userSample4, projectTasks: ProjectTask.sampleProjectTasks, projectId: Project.sampleProjects[0].id.description)
        .environmentObject(DatabaseManager())
}

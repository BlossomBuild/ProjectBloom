//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) var authManager
    
    var project: Project
    var projectTask: ProjectTask
    @State var taskName: String = ""
    @State var taskDescription: String = ""
    
    var canEditTask: Bool {
        !projectTask.isActiveTask || Constants.isProjectLeader(
            leaderID: project.projectLeaderID,
            currentUserID: authManager.userDetails?.id ?? ""
        )
    }
    
    var canCompleteTask: Bool {
        projectTask.isActiveTask && Constants.taskOwner(
            taskOwnerID: projectTask.assignedToID,
            currentUserID: authManager.userDetails?.id ?? ""
        )
    }
    
    init(project: Project,projectTask: ProjectTask){
        self.projectTask = projectTask
        self.project = project
        
        _taskName = State(initialValue: projectTask.isActiveTask ||
                          (projectTask.isCompleted != nil) ? projectTask.title : "")
        _taskDescription = State(initialValue: projectTask.description ?? "")
    }
    
    var body: some View {
        VStack {
            TextField(projectTask.title, text: $taskName, axis: .vertical)
                .padding()
                .onChange(of: taskName) { _, newValue in
                    if newValue.count > 40 {
                        taskName = String(newValue.prefix(40))
                    }
                }
            
            CharacterCounterView(currentCount: taskName.count, maxLimit: 40)
            
            Rectangle()
                .foregroundStyle(.bbGreen)
                .frame(height: 2)
            
            TextField(projectTask.description
                      ?? UIStrings.descriptionOptional.string,
                      text: $taskDescription , axis: .vertical)
            .padding()
            
            Spacer()
            
            HStack {
                if canEditTask && projectTask.isActiveTask {
                    Button {
                        unassignTask()
                        dismiss()
                    } label: {
                        Image(systemName: Constants.unassignTask)
                            .foregroundStyle(.red)
                            .font(.system(size: 35))
                    }
                }
                
                
                Spacer()
                
                if canEditTask {
                    Button {
                        if !taskName.isEmpty{
                            assignTask()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: projectTask.isActiveTask || (projectTask.isCompleted != nil) ? Constants.pencilIcon : Constants.arrowUpIcon)
                            .font(.system(size: 35))
                            .foregroundStyle(taskName.isEmpty ? .gray : .bbGreen)
                    }
                }
                
                if canCompleteTask {
                    Button {
                        completeTask()
                        dismiss()
                    } label: {
                        Image(systemName: Constants.checkMarkIcon)
                            .font(.system(size: 35))
                            .foregroundStyle(taskName.isEmpty ? .gray : .bbGreen)
                        
                    }
                }
                
            }
            .padding()
        }
    }
    
    func assignTask () {
        Task {
            try await DatabaseManager.shared.assignTask(
                projectId: project.id.description,
                projectTask: projectTask,
                newTaskName: taskName,
                newTaskDescription: taskDescription
            )
        }
    }
    
    func completeTask() {
        Task {
            var updatedProjectTask = projectTask
            
            if taskName != projectTask.title || taskDescription != (projectTask.description ?? "") {
                updatedProjectTask.title = taskName
                updatedProjectTask.description = taskDescription
            }
            
            //TODO: Add a catch block for feedback if the operation fails
            try await DatabaseManager.shared.completeTask(
                projectId: project.id.description,
                projectTask: updatedProjectTask
            )
        }
    }
    
    func unassignTask() {
        Task {
            try await DatabaseManager.shared.unassignTask(
                projectId: project.id.description,
                projectTask: projectTask
            )
        }
    }
}



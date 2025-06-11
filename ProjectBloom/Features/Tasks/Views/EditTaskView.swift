//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthViewModel.self) var authViewModel
    
    
    var project: Project
    var projectTask: ProjectTask
    @State var taskName: String = ""
    @State var taskDescription: String = ""
    
    var canEditTask: Bool {
        !projectTask.isActiveTask || Constants.isProjectLeader(
            leaderID: project.projectLeaderID,
            currentUserID: authViewModel.userDetails?.id ?? ""
        )
    }
    
    var canCompleteTask: Bool {
        projectTask.isActiveTask && Constants.taskOwner(
            taskOwnerID: projectTask.assignedToID,
            currentUserID: authViewModel.userDetails?.id ?? ""
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
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .frame(minHeight: 30)
                .onChange(of: taskName) { oldValue, newValue in
                    if newValue.count > 40 {
                        taskName = String(newValue.prefix(40))
                    }
                }
            
            CharacterCounterView(currentCount: taskName.count, maxLimit: 40)
            
            Rectangle()
                .foregroundStyle(.bbGreenDark)
                .frame(height: 2)
            
            TextField(projectTask.description
                      ?? UIStrings.descriptionOptional.string,
                      text: $taskDescription , axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .frame(minHeight: 50)
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
                            .foregroundStyle(taskName.isEmpty ? .gray : .bbGreenDark)
                    }
                }
                
                if canCompleteTask {
                    Button {
                        completeTask()
                        dismiss()
                    } label: {
                        Image(systemName: Constants.checkMarkIcon)
                            .font(.system(size: 35))
                            .foregroundStyle(taskName.isEmpty ? .gray : .bbGreenDark)
                        
                    }
                }
                
            }
            .padding()
        }
    }
    
    func assignTask () {
        Task {
            //TODO: Add a catch block for feedback if the operation fails
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

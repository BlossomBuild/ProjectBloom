//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    
    var projectId: String
    var projectTask: ProjectTask
    @State var taskName: String = ""
    @State var taskDescription: String = ""
    
    init(projectID: String,projectTask: ProjectTask){
        self.projectTask = projectTask
        self.projectId = projectID
        
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
            
            Rectangle()
                .foregroundStyle(.bbGreenDark)
                .frame(height: 2)
            
            TextField(projectTask.description
                      ?? Constants.descriptionOptionalString,
                      text: $taskDescription , axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .frame(minHeight: 50)
            Spacer()
            HStack {
                
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
                
                Spacer()
                
                if projectTask.isActiveTask {
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
                projectId: projectId,
                projectTask: projectTask,
                newTaskName: taskName,
                newTaskDescription: taskDescription
            )
        }
    }
    
    func completeTask() {
        Task {
            //TODO: Add a catch block for feedback if the operation fails
            try await DatabaseManager.shared.completeTask(
                projectId: projectId,
                projectTask: projectTask
            )
        }
    }
}

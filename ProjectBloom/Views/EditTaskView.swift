//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DatabaseViewModel.self) var databaseViewModel
    
    var projectId: String
    var projectTask: ProjectTask
    @State var taskName: String = ""
    @State var taskDescription: String = ""
    
    var body: some View {
        VStack (alignment: .leading) {
            
            TextField(projectTask.title, text: $taskName, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .frame(minHeight: 25)
            
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
                Spacer()
                Button {
                    assignTask()
                    dismiss()
                } label: {
                    Image(systemName: Constants.arrowUpIcon)
                        .font(.system(size: 35))
                        .foregroundStyle(.bbGreenDark)
                }
                
                if projectTask.isActiveTask {
                    Button {
                        
                    } label: {
                        Image(systemName: Constants.checkMarkIcon)
                            .font(.system(size: 35))
                            .foregroundStyle(.bbGreenDark)
                        
                    }
                }
                
            }
            .padding()
            
        }
    }
    
    func assignTask () {
            Task {
                do {
                    try await databaseViewModel.assignTask(
                        projectId: projectId,
                        projectTask: projectTask,
                        newTaskName: taskName
                    )
    
                } catch {
                    print("Error updating project: \(error.localizedDescription)")
                }
            }
        }
}
    //    @EnvironmentObject var databaseManager: DatabaseManager
    //    @State var taskName = ""
    //    var projectId: String
    //    var editTask: Bool // True makes a new task, False completes task
    //    var isCompletedTask: Bool // True means the task is already completed
    
    //        ZStack {
    //            VStack {
    //                if(!editTask){
    //                    Text(Constants.taskString)
    //                        .bold()
    //
    //                    Text(projectTask.title)
    //                        .padding(.bottom)
    //                        .font(.title2)
    //
    //                    Button {
    //                        completeTask()
    //                        dismiss()
    //                    } label: {
    //                        Text(Constants.completeString)
    //                            .ghostButton(borderColor: .bbGreen)
    //                    }
    //
    //                } else {
    //                    TextField(projectTask.title, text: $taskName)
    //                        .textFieldStyle(RoundedBorderTextFieldStyle())
    //                        .padding(10)
    //                        .onAppear {
    //                            if(isCompletedTask) {
    //                                taskName = projectTask.title
    //                            } else {
    //                                taskName = projectTask.isActiveTask ? projectTask.title : ""
    //                            }
    //
    //                        }
    //                        .onChange(of: taskName) {oldValue,newValue in
    //
    //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    //                                if newValue.count > 55 {
    //                                    taskName = String(newValue.prefix(55))
    //                                }
    //                            }
    //                        }
    //
    //                    CharacterCounterView(currentCount: taskName.count, maxLimit: 55)
    //
    //                    Button {
    //                        updatedTask()
    //                        dismiss()
    //                    } label: {
    //                        Text(Constants.updateString)
    //                            .ghostButton(borderColor: taskName.isEmpty ? .gray : .bbGreen)
    //                    }
    //                    .disabled(taskName.isEmpty)
    //                }
    //
    //
    //            }
    //        }
    
    
    
    //    func updatedTask () {
    //        Task {
    //            do {
    //                let firebasePath = isCompletedTask ? FirebasePaths.completedTasks.rawValue :
    //                FirebasePaths.projectTasks.rawValue
    //
    //                try await databaseManager.updateTask(projectId: projectId , projectTask: projectTask, newTaskName: taskName, fireBasePath: firebasePath)
    //
    //            } catch {
    //                print("Error updating project: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    //
    //    func completeTask () {
    //        Task {
    //            do {
    //                try await databaseManager.completeTask(
    //                    projectId: projectId,
    //                    projectTask: projectTask,
    //                    userID: projectTask.assignedToID)
    //
    //            } catch {
    //                print("Error saving completed task: \(error.localizedDescription)")
    //            }
    //        }
    //    }



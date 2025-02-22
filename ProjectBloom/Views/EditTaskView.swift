//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State var taskName = ""
    var projectId: String
    var projectTask: ProjectTask
    var editTask: Bool // True makes a new task, False completes task
    var isCompletedTask: Bool // True means the task is already completed
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                if(!editTask){
                    Text(Constants.taskString)
                        .bold()
                    
                    Text(projectTask.title)
                        .padding(.bottom)
                        .font(.title2)
                    
                    Button {
                        completeTask()
                        dismiss()
                    } label: {
                        Text(Constants.completeString)
                            .ghostButton(borderColor: .bbGreen)
                    }
                    
                } else {
                    TextField(projectTask.title, text: $taskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .onAppear {
                            if(isCompletedTask) {
                                taskName = projectTask.title
                            } else {
                                taskName = projectTask.isActiveTask ? projectTask.title : ""
                            }
                            
                        }
                        .onChange(of: taskName) {oldValue,newValue in
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if newValue.count > 55 {
                                    taskName = String(newValue.prefix(55))
                                }
                            }
                        }
                    
                    CharacterCounterView(currentCount: taskName.count, maxLimit: 55)
                    
                    Button {
                        updatedTask()
                        dismiss()
                    } label: {
                        Text(Constants.updateString)
                            .ghostButton(borderColor: taskName.isEmpty ? .gray : .bbGreen)
                    }
                    .disabled(taskName.isEmpty)
                }
                
                
            }
        }
        
    }
    
    func updatedTask () {
        Task {
            do {
                let firebasePath = isCompletedTask ? FirebasePaths.completedTasks.rawValue :
                FirebasePaths.projectTasks.rawValue
                
                try await databaseManager.updateTask(projectId: projectId , projectTask: projectTask, newTaskName: taskName, fireBasePath: firebasePath)
                
            } catch {
                print("Error updating project: \(error.localizedDescription)")
            }
        }
    }
    
    func completeTask () {
        Task {
            do {
                try await databaseManager.completeTask(
                    projectId: projectId,
                    projectTask: projectTask,
                    userID: projectTask.assignedToID)
                
            } catch {
                print("Error saving completed task: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EditTaskView(projectId: ProjectTask.sampleProjectTasks[0].id.description, projectTask: ProjectTask.sampleProjectTasks[1], editTask: true, isCompletedTask: true)
        .environmentObject(DatabaseManager())
}

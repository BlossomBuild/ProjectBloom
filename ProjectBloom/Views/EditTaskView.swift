//
//  EditTaskView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/17/24.
//

import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var databaseManager: DatabaseManager
    @State var taskName = ""
    var projectId: String
    var projectTask: ProjectTask
    var editTask: Bool
    
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.green.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
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
                        .padding()
                        .onChange(of: taskName) {oldValue,newValue in
                            if newValue.count > 45 {
                                taskName = String(newValue.prefix(45))
                            }
                        }
                    
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
            .preferredColorScheme(.light)
        }
        
    }
    
    func updatedTask () {
        Task {
            do {
                try await databaseManager.updateTask(projectId: projectId , projectTask: projectTask, newTaskName: taskName)
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
    EditTaskView(projectId: ProjectTask.sampleProjectTasks[0].id.description, projectTask: ProjectTask.sampleProjectTasks[1], editTask: false)
        .environmentObject(AuthManager())
        .environmentObject(DatabaseManager())
}

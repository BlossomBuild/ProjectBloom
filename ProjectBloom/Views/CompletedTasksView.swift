//
//  CompletedTasksView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 1/7/25.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var showUndoBanner = false
    @State private var deletedTask: ProjectTask?
    
    var project: Project
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(project.name + Constants.spaceString + Constants.completedTasksString)
                .font(.title3)
            
            List(databaseManager.completedTasks.sorted(by: {
                ($0.completedAt?.dateValue() ?? Date()) > ($1.completedAt?.dateValue() ?? Date())
            })) {projectTask in
                var formattedDate: String {
                    guard let completedAt = projectTask.completedAt?.dateValue() else
                    {return ""}
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM d, yyyy"
                    return formatter.string(from: completedAt)
                }
                
                VStack (alignment: .leading, spacing: 4){
                    Text(Constants.taskNameString  + Constants.colonString +  Constants.spaceString + projectTask.title)
                        .font(.system(size: 13))
                        .bold()
                    Text(Constants.completedByString + Constants.colonString + Constants.spaceString + projectTask.assignedToUserName)
                        .font(.system(size: 12))
                    Text(Constants.completeOnString + Constants.colonString + Constants.spaceString + formattedDate)
                        .font(.system(size: 12))
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        deleteCompletedTask(completedTask: projectTask)
                    } label: {
                        Image(systemName: Constants.trashIcon)
                    }
                }
                .tint(.red)
                
            }
            .clipShape(.rect(cornerRadius: 10))
          
        }
        .padding()
        .task {
            databaseManager.listenToProjectTasks(projectID: project.id.description, taskType: FirebasePaths.completedTasks.rawValue)
        }
        .onDisappear {
            databaseManager.stopListeningToProjectTasks(taskType: FirebasePaths.completedTasks.rawValue)
        }
        .preferredColorScheme(.light)
        
        if showUndoBanner {
            HStack {
               
                Text(Constants.taskDeletedString)
                    .font(.footnote)
                    .foregroundColor(.bbWhite)
                Spacer()
                
                Button() {
                    undoDelete()
                } label: {
                    Text(Constants.undoString)
                        .font(.footnote)
                        .foregroundStyle(.bbWhite)
                        .bold()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(.bbGreen)
                        .clipShape(.rect(cornerRadius: 4))
                }
               
            }
            .padding()
            .background(Color.gray.opacity(0.9))
            .cornerRadius(8)
            .padding(.horizontal)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: showUndoBanner)
        }
    }
    
    
    func undoDelete() {
        guard let task = deletedTask else { return }

        databaseManager.completedTasks.append(task)
        deletedTask = nil
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showUndoBanner = false
        }
        
        Task {
            do {
                try await databaseManager.addTaskBackToCompleted(projectId: project.id.description, projectTask: task)
                

            } catch {
                print("Error undoing the deletion: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    
    func deleteCompletedTask(completedTask: ProjectTask) {
        
        if let index = databaseManager.completedTasks.firstIndex(where: { $0.id == completedTask.id })
        {
            databaseManager.completedTasks.remove(at: index)
        }
        
        
        deletedTask = completedTask
        showUndoBanner = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Task {
                if deletedTask == completedTask {
                    do {
                        try await databaseManager
                            .deleteCompletedTask(projectId: project.id.description, projectTask: completedTask)
                        deletedTask = nil
                        showUndoBanner = false
                    } catch {
                        print("Error deleting the completed task: \(error.localizedDescription)")
                    }
                }
            }
        }
        
    }
}

#Preview {
    CompletedTasksView(project: Project.sampleProjects[0])
        .environmentObject(DatabaseManager())
}

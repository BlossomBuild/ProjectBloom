//
//  NewProjectView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/5/24.
//

import SwiftUI

struct ProjectEditorView: View {
    @State private var projectName = ""
    @State private var isLoading = false
    @EnvironmentObject var authManager : AuthManager
    @EnvironmentObject var databaseManager : DatabaseManager
    @Environment(\.dismiss) var dismiss
    var updateProject: Bool
    var project: Project?
    
    init(updateProject: Bool, project: Project? = nil) {
        self.updateProject = updateProject
        self.project = project
        _projectName = State(initialValue: project?.name ?? "")
    }
    
    var body: some View {
        VStack{
            TextField(Constants.projectNameString, text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel(Constants.projectNameString)
                .padding()
            
                Button {
                    isLoading = true
                    if(updateProject) {
                        updateProjectName()
                    } else {
                        createNewProject()
                    }
                    
                } label: {
                    Text(updateProject ? Constants.renameString : Constants.createString)
                        .ghostButton(borderColor: projectName.isEmpty ? .gray : .bbGreen)
                }
                .disabled(projectName.isEmpty || isLoading)
            
        }
    }
    
    func createNewProject() {
        Task {
            do {
                guard let user = authManager.user else {
                    isLoading = false
                    return
                }
               
                guard let userName = user.displayName else {
                    isLoading = false
                    return
                }
                guard let userEmail = user.email else { isLoading = false
                    return
                }
                
                let newproject = Project(name: projectName, projectLeaderID: user.uid, usersID: [user.uid], usersDetails: [UserDetails(id: user.uid, userName: userName, userEmail: userEmail)])
                
                try await databaseManager.createNewProject(projectDetails: newproject, user: user)
               
                dismiss()
                isLoading = false
                
            } catch {
                print("Error creating the project: \(error)")
                
            }
        }
    }
    
    func updateProjectName() {
        Task {
            do {
                guard let project = project else {
                    isLoading = false
                    return
                }
                try await databaseManager.updateProjectName(projectDetails: project, newProjectName: projectName)
                
                dismiss()
                isLoading = false
            } catch {
                print("Error renaming the project: \(error)")
            }
        }
    }
}



#Preview {
    ProjectEditorView(updateProject: false)
        .environmentObject(AuthManager())
        .environmentObject(DatabaseManager())
}

//
//  NewProjectView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/5/24.
//

import SwiftUI

struct EditProjectView: View {
    @State private var projectName = ""
    @State private var isLoading = false
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(DatabaseViewModel.self) var databaseViewModel
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
                .accessibilityHint(Constants.projectAccessibilityHint)
                .padding(10)
                .onChange(of: projectName) { oldValue, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        if newValue.count > 30 {
                            projectName = String(newValue.prefix(30))
                        }
                    }
                   
                }
            
            CharacterCounterView(currentCount: projectName.count, maxLimit: 30)
            
            
                Button {
                    isLoading = true
                    if(updateProject) {
                        updateProjectName()
                    } else {
                        createNewProject()
                    }
                    
                } label: {
                    Text(updateProject ? Constants.renameString : Constants.createString)
                        .ghostButton(borderColor: projectName.isEmpty ? .gray : .bbGreenDark)
                }
                .disabled(projectName.isEmpty || isLoading)
            
        }
    }
    
    func createNewProject() {
        Task {
            do {
                guard let user = authViewModel.user else {
                    isLoading = false
                    return
                }
               
                guard let userName = user.displayName else {
                    isLoading = false
                    return
                }
                
                let userEmail = user.email ?? Constants.naString
                
                let newproject = Project(name: projectName, projectLeaderID: user.uid, usersID: [user.uid], usersDetails: [UserDetails(id: user.uid, userName: userName, userEmail: userEmail)])
                
                try await databaseViewModel.createNewProject(projectDetails: newproject, user: user)
               
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
                try await databaseViewModel.updateProjectName(project: project, newProjectName: projectName)
                
                dismiss()
                isLoading = false
            } catch {
                print("Error renaming the project: \(error)")
            }
        }
    }
}



#Preview {
    EditProjectView(updateProject: false)
        .environment(AuthViewModel())
        .environment(DatabaseViewModel())
}

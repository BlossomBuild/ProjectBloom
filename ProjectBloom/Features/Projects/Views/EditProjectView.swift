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
            TextField(UIStrings.projectName.string, text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(10)
                .onChange(of: projectName) { oldValue, newValue in
                    if newValue.count > 30 {
                        projectName = String(newValue.prefix(30))
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
                Text(updateProject ? UIStrings.rename.localizedKey : UIStrings.create.localizedKey)
                    .ghostButton(borderColor: projectName.isEmpty ? .gray : .bbGreenDark)
            }
            .disabled(projectName.isEmpty || isLoading)
            
        }
    }
    
    //TODO: Add Feedback in the catch Block
    func createNewProject() {
        Task {
            do {
                guard let userDetails = authViewModel.userDetails else {
                    isLoading = false
                    return
                }
                
                let newproject = Project(
                    name: projectName,
                    projectLeaderID: userDetails.id,
                    userEmails: [userDetails.userEmail]
                )
                
                try await DatabaseManager.shared.createNewProject(
                    projectDetails: newproject,
                    userDetails: userDetails
                )
                dismiss()
                isLoading = false
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
                try await DatabaseManager.shared.updateProjectName(project: project, newProjectName: projectName)
                
                dismiss()
                isLoading = false
            } catch {
                print("Error renaming the project: \(error)")
            }
        }
    }
}

//
//  DeleteProjectView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 3/7/25.
//

import SwiftUI

struct DeleteProjectAlertView: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @Binding var isPresented: Bool
    var projectToDelete: Project
    
    var body: some View {
        Text("")
            .alert(Text(UIStrings.delete.localizedKey) +
                   Text(Punctuation.space.localizedKey) +
                   Text(projectToDelete.name),isPresented: $isPresented,
                   actions: {
                Button(UIStrings.delete.localizedKey, role:.destructive){
                    deleteProject(project: projectToDelete)
                    isPresented = false
                }
                
                Button(UIStrings.cancel.localizedKey, role: .cancel) {
                    isPresented = false // Dismiss the alert
                }
            }, message: {
                Text(UIStrings.irreversibleAction.localizedKey)
            })
        
        switch databaseViewModel.projectDeletedStatus {
        case .fetching:
            ProgressView()
        case .failed:
            Text(UIStrings.removeUserMessage.localizedKey)
        default:
            EmptyView()
        }
    }
    
    private func deleteProject(project: Project) {
        Task {
            try await databaseViewModel
                .deleteProject(projectID: project.id.description)
        }
    }
}

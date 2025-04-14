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
            .alert("\(Constants.deleteSting + Constants.spaceString)\(projectToDelete.name)",isPresented: $isPresented,
                   actions: {
                Button(Constants.deleteSting, role:.destructive){
                    deleteProject(project: projectToDelete)
                    isPresented = false
                }
                
                Button(Constants.cancelString, role: .cancel) {
                    isPresented = false // Dismiss the alert
                }
            }, message: {
                Text(AlertString.actionCantBeUndone.rawValue)
            })
        
        switch databaseViewModel.projectDeletedStatus {
        case .fetching:
            ProgressView()
        case .failed:
            Text(UserErrorMessages.deletingProjectError.rawValue)
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

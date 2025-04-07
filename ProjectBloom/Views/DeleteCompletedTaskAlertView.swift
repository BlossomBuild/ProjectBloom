//
//  DeleteCompletedTaskAlertView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/7/25.
//

import SwiftUI

struct DeleteCompletedTaskAlertView: View {
    @Binding var isPresented: Bool
    var completedTaskToDelete: ProjectTask
    var projectId: String
    
    var body: some View {
        Text("")
            .alert("\(Constants.deleteSting + Constants.spaceString)\(completedTaskToDelete.title)",isPresented: $isPresented,
                   actions: {
                Button(Constants.deleteSting, role:.destructive){
                    deleteCompletedTask()
                    isPresented = false
                }
                
                Button(Constants.cancelString, role: .cancel) {
                    isPresented = false // Dismiss the alert
                }
            }, message: {
                Text(AlertString.actionCantBeUndone.rawValue)
            })
    }
    
    private func deleteCompletedTask() {
        Task {
            try await DatabaseManager.shared.deleteCompletedTask(projectId: projectId,
                                                                 projectTask: completedTaskToDelete)
        }
    }
}

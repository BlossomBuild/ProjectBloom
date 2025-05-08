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
            .alert(Text(UIStrings.delete.localizedKey) +
                   Text(Punctuation.space.localizedKey) +
                   Text(completedTaskToDelete.title)
                   ,isPresented: $isPresented,
                   actions: {
                Button(UIStrings.delete.rawValue, role:.destructive){
                    deleteCompletedTask()
                    isPresented = false
                }
                
                Button(UIStrings.cancel.localizedKey, role: .cancel) {
                    isPresented = false // Dismiss the alert
                }
            }, message: {
                Text(UIStrings.irreversibleAction.localizedKey)
            })
    }
    
    private func deleteCompletedTask() {
        Task {
            try await DatabaseManager.shared.deleteCompletedTask(projectId: projectId,
                                                                 projectTask: completedTaskToDelete)
        }
    }
}

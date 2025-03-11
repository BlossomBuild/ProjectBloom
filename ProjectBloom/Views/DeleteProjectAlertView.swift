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
        case .failed(underlyingError: let error):
            ToastView(message: "Error deleting project please try again")
        default:
            ToastView(message: "")
        }
    }
    
    private func deleteProject(project: Project) {
        Task {
            do {
                try await databaseViewModel.deleteProject(projectID: project.id.description)
            } catch {
                print("Error deleting project: \(error.localizedDescription)")
            }
        }
    }
}


struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 10)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.5), value: message)
    }
}

#Preview {
    DeleteProjectAlertView(isPresented: .constant(true), projectToDelete: Project.sampleProjects[0])
    .environment(DatabaseViewModel())
}

//
//  DeleteUserAlert.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/30/25.
//

import SwiftUI

struct RemoveUserAlertView: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @Binding var isPresented: Bool
    var currentProject: Project
    var userToRemove: UserDetails
    
    
    var body: some View {
        Text("")
            .alert(Text(UIStrings.removeUserMessage.localizedKey)
                   + Text(Punctuation.space.localizedKey)
                   + Text(Constants.getFirstName(from: userToRemove.userName))
                   + Text(Punctuation.questionMark.localizedKey),
                   
                   
                   isPresented: $isPresented) {
                Button(UIStrings.remove.rawValue, role:.destructive){
                    removeUser(project: currentProject, userDetails: userToRemove)
                    isPresented = false
                }
                
                Button(UIStrings.cancel.localizedKey, role: .cancel) {
                    isPresented = false // Dismiss the alert
                }
            }
    }
    
    private func removeUser(project: Project, userDetails: UserDetails) {
        Task {
            try await databaseViewModel
                .removeUserFromProject(project: project, userDetails: userDetails)
        }
    }
}


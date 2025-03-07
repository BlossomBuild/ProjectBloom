//
//  DeleteProjectView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 3/7/25.
//

import SwiftUI

struct DeleteProjectAlertView: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @Binding var showDeletedAlert: Bool
    var projectToDelete: Project
    
    var body: some View {
        VStack {
            Text("\(Constants.deleteSting + Constants.spaceString)\(projectToDelete.name)")
            
            Text(AlertString.actionCantBeUndone.rawValue)
        }
    }
}

#Preview {
    DeleteProjectAlertView(showDeletedAlert: .constant(true), projectToDelete: Project.sampleProjects[0])
        .environment(DatabaseViewModel())
}

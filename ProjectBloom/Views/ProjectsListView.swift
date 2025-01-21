//
//  ProjectsList.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/7/24.
//

import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            switch(databaseManager.status) {
            case .notStarted:
                EmptyView()
                  
            case .fetching:
                ProgressView()
                   
            case .success:
                List(databaseManager.userProjects) {project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        Text(project.name)
                    }
                }
                .listStyle(.plain)
                .padding()
                
              
            case .failed(let error):
                Text(error.localizedDescription)
                  
            }
        }
        .task{
            guard let user = authManager.user else { return }
            databaseManager.listenToUserProjects(user: user)
        }
     
    }
}

#Preview {
    ProjectsListView()
        .environmentObject(AuthManager())
        .environmentObject(DatabaseManager())
}

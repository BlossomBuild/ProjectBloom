//
//  ProjectsList.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/7/24.
//

import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @Environment(AuthViewModel.self) var authViewModel
    
    @State private var greeting: String = Constants.getGreeting()
    @State private var showDeleteAlert: Bool = false
    @State private var projectToDelete: Project?
    
    var body: some View {
        NavigationStack {
            switch(databaseManager.status) {
            case .notStarted:
                EmptyView()
                
            case .fetching:
                ProgressView()
                
            case .success:
                if(databaseManager.userProjects.isEmpty) {
                    VStack(alignment: .leading) {
                        Text("\(greeting), \(Constants.getFirstName(from: authViewModel.userDetails?.userName ?? authViewModel.user?.displayName))")
                            .font(.title3)
                            .padding(25)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Spacer()
                        Text(Constants.noActiveProjectsString)
                            .font(.title3)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                          
                        Spacer()
                        
                        
                    }
                    
                } else {
                    List {
                        Text("\(greeting)" + Constants.commaString + Constants.spaceString
                             +  Constants.getFirstName(from: authViewModel.userDetails?.userName ?? authViewModel.user?.displayName))
                        .font(.title3)
                        .listRowSeparator(.hidden)
                        
                        ForEach(databaseManager.userProjects.sorted(
                            by: { $0.name < $1.name })) { project in
                                NavigationLink {
                                    ProjectDetailView(project: project)
                                } label: {
                                    Text(project.name)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        projectToDelete = project
                                        showDeleteAlert = true
                                    } label: {
                                        Image(systemName: Constants.trashIcon)
                                    }
                                }
                                .tint(.red)
                            }
                        
                    }
                    .listStyle(.plain)
                    .padding()
                    .alert("\(Constants.deleteSting + Constants.spaceString)\(projectToDelete?.name ?? "\(Constants.projectString)")",isPresented: $showDeleteAlert, actions: {
                        Button(Constants.deleteSting, role:.destructive){
                            if let project = projectToDelete {
                                deleteProject(project: project)
                            }
                            showDeleteAlert = false
                        }
                        
                        
                        
                        Button(Constants.cancelString, role: .cancel) {
                            showDeleteAlert = false // Dismiss the alert
                            projectToDelete = nil // Reset state
                        }
                    }, message: {
                        Text(AlertString.actionCantBeUndone.rawValue)
                    })
                    
                }
            case .failed(let error):
                Text(error.localizedDescription)
            }
        }
        .task {
            guard let user = authViewModel.user else { return }
            databaseManager.listenToUserProjects(user: user)
        }
        .onDisappear {
            databaseManager.stopListeningToUserProjects()
        }
        
    }
    
    private func deleteProject(project: Project) {
        Task {
            do {
                try await databaseManager.deleteProject(projectID: project.id.description)
            } catch {
                print("Error deleting project: \(error.localizedDescription)")
            }
        }
    }
    
}

#Preview {
    ProjectsListView()
        .environment(AuthViewModel())
        .environmentObject(DatabaseManager())
}

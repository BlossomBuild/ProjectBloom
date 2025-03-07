//
//  ProjectsList.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/7/24.
//

import SwiftUI

struct ProjectsListView: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @Environment(AuthViewModel.self) var authViewModel
    
    @State private var greeting: String = Constants.getGreeting()
    @State private var showDeleteAlert: Bool = false
    @State private var projectToDelete: Project?
    
    private var isUserNameLoaded: Bool {
        guard let userName = authViewModel.userDetails?.userName ?? authViewModel.user?.displayName else {
            return false
        }
        return !userName.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            if !isUserNameLoaded{
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                    Text(Constants.loadingUserInfoString)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                switch(databaseViewModel.userProjectsStatus) {
                case .notStarted:
                    EmptyView()
                    
                case .fetching:
                    ProgressView()
                    
                case .success:
                    if(databaseViewModel.userProjects.isEmpty) {
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
                            
                            ForEach(databaseViewModel.userProjects.sorted(
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
        }
        .task {
            guard let user = authViewModel.user else {
                return
            }
            databaseViewModel.listenToUserProjects(user: user)
        }
        .onDisappear {
            databaseViewModel.stopListeningToUserProjects()
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

#Preview {
    ProjectsListView()
        .environment(AuthViewModel())
        .environment(DatabaseViewModel())
}

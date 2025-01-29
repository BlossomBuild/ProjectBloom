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
    
    @State private var greeting: String = ""
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
                List {
                    Text("\(greeting)" + Constants.commaString + Constants.spaceString
                         +  getFirstName(fullName: authManager.user?.displayName))
                    .font(.title3)
                    .listRowSeparator(.hidden)
                    
                    ForEach(databaseManager.userProjects) { project in
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
                .onAppear {
                    updateGreeting()
                }
                
            case .failed(let error):
                Text(error.localizedDescription)
            }
        }
        .task{
            guard let user = authManager.user else { return }
            databaseManager.listenToUserProjects(user: user)
        }
        
    }
    
    private func updateGreeting(){
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            greeting = Constants.goodMorningString
            
        case 12..<18:
            greeting = Constants.goodAfternoonString
            
        case 18..<24:
            greeting = Constants.goodEveningString
        default:
            greeting = Constants.helloString
        }
    }
    
    private func getFirstName(fullName: String?) -> String {
        guard let fullName = fullName else {
            return ""
        }
        
        return fullName.components(separatedBy: " ").first ?? ""
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
        .environmentObject(AuthManager())
        .environmentObject(DatabaseManager())
}

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
    @State private var projectToEdit: Project?
    
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
                            Text(UIStrings.noActiveProjects.localizedKey)
                                .font(.title3)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Spacer()
                        }
                        
                    } else {
                        List {
                            Group {
                                Text(greeting) +
                                Text(Punctuation.comma.localizedKey) +
                                Text(Punctuation.space.localizedKey) +
                                Text(Constants.getFirstName(from: authViewModel.userDetails?.userName ??
                                                            authViewModel.user?.displayName))
                            }
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
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            projectToEdit = project
                                        } label : {
                                            Image(systemName: Constants.editIcon)
                                                

                                        }
                                    }
                                    .tint(.yellow)
                                }
                            
                            
                        }
                        .listStyle(.plain)
                        .padding()
                        .sheet(item: $projectToEdit) { project in
                            EditProjectView(updateProject: true,
                                            project: project)
                            .presentationDetents([.fraction(0.25)])
                        }
                        
                        
                        if let project = projectToDelete {
                            DeleteProjectAlertView(
                                isPresented: $showDeleteAlert,
                                projectToDelete: project
                            )
                        }
                    }
                case .failed:
                    Text(UIStrings.genericErrorMessage.localizedKey)
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
    
}

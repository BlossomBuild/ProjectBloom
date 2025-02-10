//
//  HomeView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State var showAccountScreen: Bool = false
    @State var showCreateProjectScreen: Bool = false
    
    var body: some View {
        NavigationStack() {
                switch authManager.authState {
                case .signedIn:
                    
                    ProjectsListView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showAccountScreen.toggle()
                                } label: {
                                    Image(systemName: Constants.signedInImage)
                                        .tint(.bbWhite)
                                }
                            }
                            
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showCreateProjectScreen.toggle()
                                } label : {
                                    Image(systemName: Constants.addProjectImage)
                                        .tint(.bbWhite)
                                }
                            }
                        }
                    
                        .sheet(isPresented: $showAccountScreen) {
                            AccountView()
                                .presentationDetents([.fraction(0.50)])
                        }
                        .sheet(isPresented: $showCreateProjectScreen) {
                            EditProjectView(updateProject: false)
                                .presentationDetents([.fraction(0.25)])
                        }
                        .navigationTitle(Constants.projectsString)
                                    
                case .anonymousAuth:
                    Text("Signed in Anonymous")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showAccountScreen.toggle()
                                } label: {
                                    Image(systemName: Constants.signedOutImage)
                                }
                            }
                        }
                        .sheet(isPresented: $showAccountScreen) {
                            LoginView()
                        }
                    
                case.signedOut:
                    LoginView()
                }
            
        }
        .tint(.bbWhite)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}




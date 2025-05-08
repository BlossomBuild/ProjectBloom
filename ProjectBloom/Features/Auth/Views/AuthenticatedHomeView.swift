//
//  AuthenticatedHomeView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 2/26/25.
//

import SwiftUI

struct AuthenticatedHomeView: View {
    let isAnonymous: Bool
    @State private var showAccountScreen = false
    @State private var showCreateProjectScreen = false
    
    var body: some View {
        ProjectsListView()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAccountScreen.toggle()
                    } label: {
                        Image(systemName: isAnonymous ? Constants.signedOutIcon : Constants.signedInIcon)
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
                Group {
                    if isAnonymous {
                        LoginView()
                    } else {
                        AccountView()
                            .presentationDetents([.fraction(0.50)])
                    }
                }
                
            }
            .sheet(isPresented: $showCreateProjectScreen) {
                EditProjectView(updateProject: false)
                    .presentationDetents([.fraction(0.25)])
            }
            .navigationTitle(UIStrings.projects.localizedKey)
    }
}

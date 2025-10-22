//
//  HomeView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthManager.self) var authViewModel
    
    
    var body: some View {
        NavigationStack() {
            switch authViewModel.authState {
            case .signedIn:
                AuthenticatedHomeView(isAnonymous: false)
                
            case .anonymous:
                AuthenticatedHomeView(isAnonymous: true)
                
            case.signedOut:
                LoginView()
            }
        }
        .tint(.bbWhite)
    }
}



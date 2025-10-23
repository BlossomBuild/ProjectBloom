//
//  ContentView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) var authManager
    
    var body: some View {
        NavigationStack() {
            switch authManager.authState {
            
            case.signedOut:
                LoginView()
                
            default:
                AuthenticatedHomeView()
            }
        }
        .tint(.bbWhite)
    }
}

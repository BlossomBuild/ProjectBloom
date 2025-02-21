//
//  ContentView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @Environment(AuthViewModel.self) var authViewModel
    
    var body: some View {
        VStack {
            if authViewModel.authState != .signedOut {
                HomeView()
           
            } else {
                LoginView()
            }
        }
    
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}

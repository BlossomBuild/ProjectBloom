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
    @Environment(DatabaseViewModel.self) var databaseViewModel
    
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

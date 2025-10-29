//
//  ProjectBloomApp.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI
import FirebaseCore

@main
struct ProjectBloomApp: App {
    @State var authManger: AuthManager
    @State var databaseViewModel: DatabaseViewModel
    
    init() {
        FirebaseApp.configure()
        self.authManger = AuthManager()
        self.databaseViewModel = DatabaseViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManger)
                .environment(databaseViewModel)
        }
    }
}

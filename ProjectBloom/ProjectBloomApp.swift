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
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.bbGreen
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.bbWhite]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.bbWhite]
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManger)
                .environment(databaseViewModel)
                .preferredColorScheme(.dark)
        }
    }
}

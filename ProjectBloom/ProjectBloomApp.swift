//
//  ProjectBloomApp.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      return true
  }
}

@main
struct ProjectBloomApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager: AuthManager
    @StateObject var databaseManager: DatabaseManager
    
    init() {
        FirebaseApp.configure()
        let authManager = AuthManager()
        let databaseManager = DatabaseManager()
        _authManager = StateObject(wrappedValue: authManager)
        _databaseManager = StateObject(wrappedValue: databaseManager)
        
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
                .environmentObject(authManager)
                .environmentObject(databaseManager)
        }
    }
}





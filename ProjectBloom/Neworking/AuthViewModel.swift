//
//  AuthViewModel.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 2/19/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

@Observable
class AuthViewModel {
    enum AuthState{
        case anonymous
        case signedIn
        case signedOut
    }
    
    var authState: AuthState = .signedOut
    var user: User? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    init(){
        checkAuthState()
    }
    
    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.authState = currentUser.isAnonymous ? .anonymous : .signedIn
            
        } else {
            self.authState = .signedOut
        }
    }
    
    func signOut() {
        do {
            try AuthManager.shared.signOut()
            self.user = nil
            self.authState = .signedOut
        } catch {
            print("Error signing out: \(error)")
            self.errorMessage = "Failed to sign out"
        }
    }
    
    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthManager.shared.signInAnonymously()
            self.user = result.user
            self.authState = .anonymous
            print("Signed in anonymously as: \(result.user.uid)")
        } catch {
            print("Failed to sign in anonymously: \(error)")
            self.errorMessage = "Failed to sign in anonymously"
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = await windowScene.windows.first?.rootViewController else {
                errorMessage = "Could not get root view controller"
                isLoading = false
                return
            }
            
            let googleUser = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController).user
            
            let result = try await AuthManager.shared.signInWithGoogle(user: googleUser)
            
            self.user = result.user
            self.authState = .signedIn
            print("Signed in with Google as: \(result.user.uid)")
            
        } catch {
            print("Google sign-in failed: \(error)")
            self.errorMessage = "Google sign-in failed"
        }
        
        isLoading = false
    }
}

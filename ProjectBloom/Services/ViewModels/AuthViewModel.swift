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
    var userDetails: UserDetails? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init(){
        configureAuthStateListener()
        checkAuthState()
    }
    
    // MARK: Firebase Auth State Listener
    private func configureAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                self.user = user
                self.authState = user.isAnonymous ? .anonymous : .signedIn
                self.loadUserDetails(userID: user.uid)
            } else {
                self.authState = .signedOut
            }
            
            print("Auth State changed: \(self.authState)")
        }
    }
    
    func checkAuthState() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.authState = currentUser.isAnonymous ? .anonymous : .signedIn
            
        } else {
            self.authState = .signedOut
        }
    }
    
    deinit{
        if let authStateListener = authStateListener {
            Auth.auth().removeStateDidChangeListener(authStateListener)
        }
    }
    
    
    //MARK: Load User Details
    private func loadUserDetails(userID: String){
        Task { [weak self] in
            guard let self = self else { return }
            do {
                self.userDetails  = try await AuthManager.shared.fetchUserDetails(userID: userID)
            } catch {
                print("Failed to fetch user details: \(error)")
            }
        }
    }
    
   
    // MARK: Signout
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
    
    
    // MARK: Anon Sign In
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
    
    //MARK: Google Sign In
    func signInWithGoogle() async {
        isLoading = true
        do {
            guard let googleUser = try await GoogleSignInManager.shared.signInWithGoogle() else {
                errorMessage = "Error, please try again"
                isLoading = false
                return
            }
            
            let result = try await AuthManager.shared.signInWithGoogle(user: googleUser)
            
            user = result.user
            authState = .signedIn
            isLoading = false
            print("Signed in with Google as: \(result.user.uid)")
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("Google sign-in failed: \(error)")
        }
        
        if errorMessage != nil {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.errorMessage = nil
            }
        }
    }
}

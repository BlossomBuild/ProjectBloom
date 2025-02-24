//
//  AuthManager.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/23/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

class AuthManager {
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    let database = Firestore.firestore()
    
    private let authLinkErrors: [AuthErrorCode] = [
        .emailAlreadyInUse,
        .credentialAlreadyInUse,
        .providerAlreadyLinked,
    ]
    
    private var authStateListener: AuthStateDidChangeListenerHandle!
    
    
    
    private init() {}
    
    // MARK: Fetch User Details from Firestore
    func fetchUserDetails(userID: String) async throws -> UserDetails? {
        let userRef = database.collection(FirebasePaths.userDetails.rawValue).document(userID)
        
        do {
            let document = try await userRef.getDocument()
            if let data = document.data() {
                let userDetails = try Firestore.Decoder().decode(UserDetails.self, from: data)
                print("Fetched user details: \(userDetails)")
                return userDetails
            } else {
                print("No user details found for ID: \(userID)")
                return nil
            }
        } catch {
            print("Error fetching user details: \(error)")
            throw error
        }
    }
    
    
    
    // MARK: Sign in Anonymously
    func signInAnonymously() async throws -> AuthDataResult {
        do {
            let result = try await auth.signInAnonymously()
            print("Signed in anonymously:\(result.user.uid)")
            
            try await saveUserToFireStore(user: result.user)
            return result
        } catch {
            print("Error signing in anonymously: \(error)")
            throw error
        }
    }
    
    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            guard let user = auth.currentUser else {
                return nil
            }
            
            
            let result = try await user.link(with: credentials)
            await updateDisplayName(for: result.user)
            return result
        } catch {
            if let error = error as NSError? {
                if let code = AuthErrorCode.self(rawValue: error.code),
                   authLinkErrors.contains(code) {
                    return try await self.authSignIn(credentials: credentials)
                }
            }
            print("Firebase Auth Error: link(with:) failed, \(error)")
            throw error
        }
        
    }
    
    
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult {
        do {
            let result = try await auth.signIn(with: credentials)
            return result
        } catch {
            print("FirebaseAuthError: signIn(with:) failed: \(error)")
            throw error
        }
    }
    
    private func updateDisplayName(for user: User) async {
        if let currentDisplayName = user.displayName, !currentDisplayName.isEmpty {
            return // The user already has a name, so no need to override.
        }
        
        let displayName = user.providerData.first?.displayName
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        do {
            try await changeRequest.commitChanges()
            print("Display name updated to: \(displayName ?? "Unknown")")
        } catch {
            print("Failed to update display name: \(error)")
        }
    }
    
    
    
    
    // MARK: Google Sign In
    func signInWithGoogle(user: GIDGoogleUser) async throws -> AuthDataResult {
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(
                domain: "AuthManager",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Google ID Token"])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        do {
            let result = try await auth.signIn(with: credential)
            print("Signed in with Google: \(result.user.uid)")
            
            try await saveUserToFireStore(user: result.user)
            return result
        } catch {
            print("Google sign-in error: \(error)")
            throw error
        }
    }
    
    // MARK: -Save User to Firestore
    private func saveUserToFireStore(user: User) async throws {
        let userRef = database
            .collection(FirebasePaths.userDetails.rawValue)
            .document(user.uid)
        
        
        let document = try await userRef.getDocument()
        
        if document.exists {
            print("User already exists in Firestore: \(user.uid)")
            return
        }
        
        let userDetails = UserDetails(
            id: user.uid,
            userName: user.displayName ?? "Anonymous",
            userEmail: user.email ?? ""
        )
        
        do {
            try userRef.setData(from: userDetails)
            print("User saved to Firestore: \(user.uid)")
        } catch {
            print("Error saving user to Firestore: \(error)")
            throw error
        }
    }
    
    // MARK: - Sign out
    func signOut() throws {
        
        if let user = auth.currentUser {
            do {
                signOUtFromProviders(user)
                try auth.signOut()
                print("User signed out")
            } catch {
                print("Error signing out: \(error)")
                throw error
            }
        }
    }
    
    private func signOUtFromProviders( _ user: User) {
        let providers = user.providerData.map { $0.providerID }
        
        if providers.contains("google.com") {
            GIDSignIn.sharedInstance.signOut()
            print("Signed out from Google")
        }
    }
    
    
}


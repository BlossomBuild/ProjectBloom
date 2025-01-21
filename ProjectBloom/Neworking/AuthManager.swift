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

enum AuthState {
    case anonymousAuth
    case signedIn
    case signedOut
}

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var authState = AuthState.anonymousAuth

    let database = Firestore.firestore()
    
    private let authLinkErrors: [AuthErrorCode] = [
        .emailAlreadyInUse,
        .credentialAlreadyInUse,
        .providerAlreadyLinked,
    ]
    
    private var authStateListener: AuthStateDidChangeListenerHandle!
    
    
    init() {
        configureAuthStateChanges()
    }
    
    func configureAuthStateChanges() {
        authStateListener = Auth.auth().addStateDidChangeListener { auth, user in
            print("Auth changed: \(user != nil)")
            self.updateState(user: user)
        }
    }
    
    func removeAuthStateListener() {
        Auth.auth().removeStateDidChangeListener(authStateListener)
    }
    
    func updateState(user: User?) {
        self.user = user
        let isAuthenticatedUser = user != nil
        let isAnonymous = user?.isAnonymous ?? false
        
        if isAuthenticatedUser {
            self.authState = isAnonymous ? .anonymousAuth : .signedIn
        } else {
            self.authState = .signedOut
        }
        
        print("Auth state: \(self.authState)")
    }
    
    // MARK: Signout Functions
    func signOut() async throws {
        if let user = Auth.auth().currentUser {
            do {
                firebaseProviderSignOut(user)
                try Auth.auth().signOut()
            } catch {
                print("Firebase Auth Error: Failed to sign out from Firebase, \(error)")
                throw error
            }
        }
    }
    
    func firebaseProviderSignOut(_ user: User) {
        let providers = user.providerData.map{$0.providerID}.joined(separator: ", ")
        
        if providers.contains("google.com"){
            GoogleSignInManager.shared.signOutFromGoogle()
        }
    }

    
    
    
    // MARK: Signin Functions
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signIn(with: credentials)
            updateState(user: result.user)
            return result
        } catch {
            print("FirebaseAuthError: signIn(with:) failed: \(error)")
            throw error
        }
    }
    
    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            guard let user = Auth.auth().currentUser else {
                return nil
            }
            
            let result = try await user.link(with: credentials)
            await updateDisplayName(for: result.user)
            updateState(user: result.user)
            return result
        } catch {
            if let error = error as NSError? {
                if let code = AuthErrorCode.self(rawValue: error.code),
                   authLinkErrors.contains(code) {
                    //TODO: Get rid of the old Auth ID? Somehow lol
                    return try await self.authSignIn(credentials: credentials)
                }
            }
            print("Firebase Auth Error: link(with:) failed, \(error)")
            throw error
        }
    }
    
    private func updateDisplayName (for user:User) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty{ 
            // The user name exist and we don't want to override it
        } else {
            let displayName = user.providerData.first?.displayName
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
        }
    }
    
    private func authenticateUser(credentials: AuthCredential) async throws -> AuthDataResult? {
        if Auth.auth().currentUser != nil {
            return try await authLink(credentials: credentials)
        } else {
            return try await authSignIn(credentials: credentials)
        }
    }
    
    func writeUserDetails (_ userDetails: UserDetails, userId: String) {
        let userDetailRef = database.collection(FirebasePaths.userDetails.rawValue).document(userId)
        userDetailRef.getDocument(as: UserDetails.self) { result in
            switch result {
            case .success(_):
                // the userDetails are already saved
                return
            case .failure(_):
                do {
                    try self.database.collection(FirebasePaths.userDetails.rawValue).document(userId).setData(from: userDetails)
                    print("Document add with Id: \(userId)")
                } catch {
                    print("Error adding document: \(error)")
                }
                return
            }
        }
    }
    
    func signInAnonymously() async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("FirebaseAuthSuccess: Sign in anonymously, UID: (\(String(describing: result.user.uid))")
            return result
        } catch {
            print("FirebaseAuthError: Failed to sign in anonymously: \(error.localizedDescription)")
            throw error
        }
    }
    
    func googleAuth(_ user: GIDGoogleUser) async throws -> AuthDataResult? {
        guard let idToken = user.idToken?.tokenString else {
            return nil
        }
        
        let credentials = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        
        do {
            return try await authenticateUser(credentials: credentials)
        } catch {
            print("FirebaseAuthError: googleAuth(user:) failed. \(error)")
            throw error
        }
    }
}



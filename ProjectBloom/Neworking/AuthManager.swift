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

    private init() {}
    
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
        do {
            try auth.signOut()
            print("User signed out")
        } catch {
            print("Error signing out: \(error)")
            throw error
        }
    }

    
    
    
//    
//    
//    
//    private let authLinkErrors: [AuthErrorCode] = [
//        .emailAlreadyInUse,
//        .credentialAlreadyInUse,
//        .providerAlreadyLinked,
//    ]
//    
//    private var authStateListener: AuthStateDidChangeListenerHandle!
//    
//    
//    init() {
//        configureAuthStateChanges()
//    }
//    
//    func configureAuthStateChanges() {
//        authStateListener = Auth.auth().addStateDidChangeListener { auth, user in
//            print("Auth changed: \(user != nil)")
//            self.updateState(user: user)
//        }
//    }
//    
//    func removeAuthStateListener() {
//        Auth.auth().removeStateDidChangeListener(authStateListener)
//    }
//    
//    func updateState(user: User?) {
//        self.user = user
//        let isAuthenticatedUser = user != nil
//        let isAnonymous = user?.isAnonymous ?? false
//        
//        if isAuthenticatedUser {
//            self.authState = isAnonymous ? .anonymousAuth : .signedIn
//        } else {
//            self.authState = .signedOut
//        }
//        
//        print("Auth state: \(self.authState)")
//    }
//    
//    // MARK: Signout Functions
//    func signOut() async throws {
//        if let user = Auth.auth().currentUser {
//            do {
//                firebaseProviderSignOut(user)
//                try Auth.auth().signOut()
//            } catch {
//                print("Firebase Auth Error: Failed to sign out from Firebase, \(error)")
//                throw error
//            }
//        }
//    }
//    
//    func firebaseProviderSignOut(_ user: User) {
//        let providers = user.providerData.map{$0.providerID}.joined(separator: ", ")
//        
//        if providers.contains("google.com"){
//            GoogleSignInManager.shared.signOutFromGoogle()
//        }
//    }
//
//    
//    
//    
//    // MARK: Signin Functions
//    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult? {
//        do {
//            let result = try await Auth.auth().signIn(with: credentials)
//            updateState(user: result.user)
//            return result
//        } catch {
//            print("FirebaseAuthError: signIn(with:) failed: \(error)")
//            throw error
//        }
//    }
//    
//    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
//        do {
//            guard let user = Auth.auth().currentUser else {
//                return nil
//            }
//            
//            let result = try await user.link(with: credentials)
//            await updateDisplayName(for: result.user)
//            updateState(user: result.user)
//            return result
//        } catch {
//            if let error = error as NSError? {
//                if let code = AuthErrorCode.self(rawValue: error.code),
//                   authLinkErrors.contains(code) {
//                    //TODO: Get rid of the old Auth ID? Somehow lol
//                    return try await self.authSignIn(credentials: credentials)
//                }
//            }
//            print("Firebase Auth Error: link(with:) failed, \(error)")
//            throw error
//        }
//    }
//    
//    private func updateDisplayName (for user:User) async {
//        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty{ 
//            // The user name exist and we don't want to override it
//        } else {
//            let displayName = user.providerData.first?.displayName
//            let changeRequest = user.createProfileChangeRequest()
//            changeRequest.displayName = displayName
//        }
//    }
//    
//    private func authenticateUser(credentials: AuthCredential) async throws -> AuthDataResult? {
//        if Auth.auth().currentUser != nil {
//            return try await authLink(credentials: credentials)
//        } else {
//            return try await authSignIn(credentials: credentials)
//        }
//    }
//    
//    func writeUserDetails (_ userDetails: UserDetails, userId: String) {
//        let userDetailRef = database.collection(FirebasePaths.userDetails.rawValue).document(userId)
//        userDetailRef.getDocument(as: UserDetails.self) { result in
//            switch result {
//            case .success(_):
//                // the userDetails are already saved
//                return
//            case .failure(_):
//                do {
//                    try self.database.collection(FirebasePaths.userDetails.rawValue).document(userId).setData(from: userDetails)
//                    print("Document add with Id: \(userId)")
//                } catch {
//                    print("Error adding document: \(error)")
//                }
//                return
//            }
//        }
//    }
//    
//    func signInAnonymously() async throws -> AuthDataResult? {
//        do {
//            let result = try await Auth.auth().signInAnonymously()
//            print("FirebaseAuthSuccess: Sign in anonymously, UID: (\(String(describing: result.user.uid))")
//            return result
//        } catch {
//            print("FirebaseAuthError: Failed to sign in anonymously: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    func googleAuth(_ user: GIDGoogleUser) async throws -> AuthDataResult? {
//        guard let idToken = user.idToken?.tokenString else {
//            return nil
//        }
//        
//        let credentials = GoogleAuthProvider.credential(
//            withIDToken: idToken,
//            accessToken: user.accessToken.tokenString
//        )
//        
//        do {
//            return try await authenticateUser(credentials: credentials)
//        } catch {
//            print("FirebaseAuthError: googleAuth(user:) failed. \(error)")
//            throw error
//        }
//    }
}



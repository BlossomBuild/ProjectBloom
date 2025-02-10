//
//  LoginView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/13/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
   
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Text(Constants.appName)
                    .foregroundStyle(Color(.bbWhite))
                    .padding()
                    .font(.poppinsFontBold)
                
                Spacer()
                
                // MARK: GOOGLE SIGN IN
                GoogleSignInButton {
                    Task {
                        await signInWithGoogle()
                    }
                    
                }
                .frame(width: 280, height: 45, alignment: .center)

                // MARK: Anonymous
                if(authManager.authState == .signedOut){
                    Button {
                        signAnonymously()
                    } label: {
                        Text(Constants.skipString)
                            .font(.body.bold())
                            .frame(width: 280, height: 45, alignment: .center)
                            .foregroundStyle(.bbWhite)
                            .font(.poppinsFontRegular)
                    }
                }
               
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
        }
    }
    
    func signAnonymously() {
        Task {
            do {
                try await authManager.signInAnonymously()
            } catch {
                print("SignInAnonymouslyError: \(error)")
            }
        }
    }
    
    
    func signInWithGoogle() async {
        do {
            guard let user = try await GoogleSignInManager.shared.signInWithGoogle() else {return}
            
            let result = try await authManager.googleAuth(user)
            
            
            if let result = result {
                let userDetails = UserDetails(id: result.user.uid, userName: result.user.displayName ?? "", userEmail: result.user.email ?? "")
                
                authManager.writeUserDetails(userDetails, userId: result.user.uid)
                
                print("Google Sign In Success: \(result.user.uid)")
                dismiss()
            }
            
        } catch {
            print("Google Sign In Error: Failed to Sign in with Google, \(error)")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

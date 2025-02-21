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
    @Environment(AuthViewModel.self) var authViewModel
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
                        await authViewModel
                            .signInWithGoogle()
                    }
                    
                }
                .frame(width: 280, height: 45, alignment: .center)
                .disabled(authViewModel.isLoading)

                // MARK: Anonymous
                if(authViewModel.authState == .signedOut){
                    Button {
                        Task {
                            await authViewModel.signInAnonymously()
                        }
                    } label: {
                        Text(Constants.skipString)
                            .font(.body.bold())
                            .frame(width: 280, height: 45, alignment: .center)
                            .foregroundStyle(.bbWhite)
                            .font(.poppinsFontRegular)
                    }
                    .disabled(authViewModel.isLoading)
                }
                
                // MARK: Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
               
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
}

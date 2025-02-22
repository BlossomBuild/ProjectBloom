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
    @State private var isSigningIn: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text(Constants.appName)
                    .foregroundStyle(Color(.bbWhite))
                    .font(.poppinsFontBold)
                    .padding()
                
                Spacer()
                
                
                //MARK: GOOGLE SIGN IN
                if isSigningIn {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding().background(Color(.bbGreenDark))
                } else {
                    
                    GoogleSignInButton {
                        Task {
                            isSigningIn = true
                            await authViewModel
                                .signInWithGoogle()
                            dismiss()
                            isSigningIn = false
                        }
                        
                    }
                    .frame(width: 280, height: 45, alignment: .center)
                    .disabled(authViewModel.isLoading)
                    
                }
                
                // MARK: Anonymous
                if(authViewModel.authState == .signedOut){
                    Button {
                        Task {
                            isSigningIn = true
                            await authViewModel.signInAnonymously()
                            dismiss()
                            isSigningIn = false
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

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
                    
                    Text(UIStrings.appName.localizedKey)
                        .foregroundStyle(Color(.bbWhite))
                        .font(.poppinsFontBold)
                        .padding()
                    
                    Spacer()
                    
                    if authViewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        LoginButtonView(
                            title: UIStrings.continueWithApple.localizedKey,
                            iconName: Constants.appleLogo,
                            isSystemImage: true
                        ) {
                           
                        }
                        
                        LoginButtonView(
                            title: UIStrings.continueWithGoogle.localizedKey,
                            iconName: Constants.google,
                            isSystemImage: false
                        ) {
                            Task {
                                await authViewModel
                                    .signInWithGoogle()
                                dismiss()
                            }
                        }
                        
                        LoginButtonView(
                            title: UIStrings.continueWithEmail.localizedKey,
                            iconName: Constants.emailIcon,
                            isSystemImage: true
                        ) {
                            
                        }
                        
                        if(authViewModel.authState == .signedOut) {
                            LoginButtonView(
                                title: UIStrings.continueAnonymously.localizedKey,
                                iconName: Constants.signedOutIcon,
                                isSystemImage: true
                            ) {
                                Task {
                                    await authViewModel.signInAnonymously()
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
        }
    }
}

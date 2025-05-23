//
//  LoginView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/13/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(\.dismiss) var dismiss
    @State var showEmailLogin = false
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        
                        Text(UIStrings.appName.localizedKey)
                            .foregroundStyle(Color(.bbWhite))
                            .font(.poppinsFontBold)
                            .padding(.top, 100)
                            .padding(.bottom, 100)
                        
                        LoginButtonView(
                            title: UIStrings.continueWithApple.localizedKey,
                            iconName: Constants.appleLogo,
                            isSystemImage: true
                        ) {
                            
                        }
                        .disabled(authViewModel.isLoading)
                        
                        
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
                        .disabled(authViewModel.isLoading)
                        
                        
                        LoginButtonView(
                            title: UIStrings.continueWithEmail.localizedKey,
                            iconName: Constants.emailIcon,
                            isSystemImage: true
                        ) {
                            showEmailLogin.toggle()
                        }
                        .disabled(authViewModel.isLoading)
                        
                        if authViewModel.authState == .signedOut {
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
                        
                        if showEmailLogin {
                            Spacer()
                            EmailPasswordView()
                        }
                        
                        
                        
                    }
                }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
            .scrollIndicators(.hidden)
        }
    }
}

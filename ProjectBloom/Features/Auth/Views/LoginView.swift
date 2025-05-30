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
    
    var body: some View {
        NavigationStack {
            
            LazyVStack(spacing: 16) {
                
                Text(UIStrings.appName.localizedKey)
                    .foregroundStyle(Color(.bbWhite))
                    .font(.poppinsFontBold)
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                
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
                
                Spacer()
                
                Rectangle()
                    .foregroundStyle(.bbWhite)
                    .frame(height: 2)
                
                Spacer()
                
                EmailLoginView()
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
            .overlay {
                if authViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
            }
        }
        .tint(.white)
    }
}

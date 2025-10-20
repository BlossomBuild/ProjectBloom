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
                Text("Project Bloom")
                    .foregroundStyle(.bbWhite)
                    .font(.poppinsFontBold)
                    .padding()
                
                LoginButtonView(title: "Continue With Apple", iconName: "Apple Logo", isSystemImage: true) {
                    
                }
                .disabled(authViewModel.isLoading)
                
                
                
                LoginButtonView(title: "Continue With Google", iconName: "google", isSystemImage: false) {
                    
                    Task {
                        await authViewModel
                            .signInWithGoogle()
                        dismiss()
                    }
                    
                }
                .disabled(authViewModel.isLoading)
                
                if authViewModel.authState == .signedOut {
                    LoginButtonView(
                        title: "Continue Anonymously",
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
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreenDark))
            .overlay {
                if authViewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

import SwiftUI

struct LoginButtonView: View {
    let title: String
    let iconName: String
    let isSystemImage: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label : {
            HStack {
                Group {
                    if isSystemImage {
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.headline)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 10))
            
        }
    }
}


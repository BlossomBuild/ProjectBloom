//
//  LoginView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/13/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) var authViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Project Bloom")
                    .foregroundStyle(.bbWhite)
                    .font(.poppinsFontBold)
                    .padding()
                
                Spacer()
                
                LoginButtonView(
                    title: "Continue With Apple",
                    systemIcon: "apple.logo"
                ) {
                    
                }
                .disabled(authViewModel.isLoading)
                
                LoginButtonView(
                    title: "Continue With Google",
                    assetIcon: "google"
                ) {
                    Task {
                        await authViewModel.signInWithGoogle()
                    }
                }
                .disabled(authViewModel.isLoading)

                
                if authViewModel.authState == .signedOut {
                    LoginButtonView(
                        title: "Continue Anonymously",
                        systemIcon: "person.crop.circle.badge.questionmark"
                    ) {
                        Task {
                            await authViewModel.signInAnonymously()
                            dismiss()
                        }
                    }
                    .disabled(authViewModel.isLoading)
                }
                
                Text(authViewModel.errorMessage ?? "")
                    .frame(height: 50)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.bbGreen))
            .overlay {
                if authViewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

struct LoginButtonView: View {
    let title: String
    let systemIcon: String?
    let assetIcon: String?
    let action: () -> Void
    
    init(title: String, systemIcon: String? = nil, assetIcon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemIcon = systemIcon
        self.assetIcon = assetIcon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label : {
            HStack {
                Group {
                    if let systemIcon = systemIcon {
                        Image(systemName: systemIcon)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if let assetIcon = assetIcon {
                        Image(assetIcon)
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
            .foregroundStyle(.bbWhite)
            .padding()
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 10))
        }
    }
}


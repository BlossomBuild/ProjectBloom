//
//  AccountView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/26/24.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isSigningOut: Bool = false
    
    
    var body: some View {
        VStack {
            Spacer()
            
            if isSigningOut {
                ProgressView(Constants.signingOutString)
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                
                
            } else {
                Text(authViewModel.user?.displayName ?? Constants.userName)
                    .font(.title2)
                
                Text(authViewModel.user?.email ?? Constants.userEmail)
                    .font(.title2)
            }
            
            
            
            Spacer()
            Button {
                Task {
                    isSigningOut = true
                    await authViewModel.signOut()
                    dismiss()
                }
            } label: {
                Text(Constants.signOutString)
                    .ghostButton(borderColor: .red)
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
}

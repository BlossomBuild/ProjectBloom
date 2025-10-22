//
//  AccountView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/26/24.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) var authViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isSigningOut: Bool = false
    
    
    var body: some View {
        VStack {
            Spacer()
            
            if isSigningOut {
                ProgressView(UIStrings.signingOut.localizedKey)
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                
                
            } else {
                Text(authViewModel.user?.displayName ?? UIStrings.userName.string)
                    .font(.title2)
                
                Text(authViewModel.user?.email ?? UIStrings.userEmail.string)
                    .font(.title2)
            }

            Spacer()
            Button {
                Task {
                    isSigningOut = true
                    authViewModel.signOut()
                    dismiss()
                }
            } label: {
                Text(UIStrings.signOut.localizedKey)
                    .ghostButton(borderColor: .red)
            }
        }
    }
}

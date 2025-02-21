//
//  AccountView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/26/24.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) var authViewModel

    
    var body: some View {
        VStack {
            Spacer()
            
            Text(authViewModel.user?.displayName ?? Constants.userName)
                .font(.title2)
            
            Text(authViewModel.user?.email ?? Constants.userEmail)
                .font(.title2)
            
            Spacer()
            Button {
                signOut()
            } label: {
                Text(Constants.signOutString)
                    .ghostButton(borderColor: .red)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authViewModel.signOut()
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
}

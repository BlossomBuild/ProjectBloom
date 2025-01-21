//
//  AccountView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/26/24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(authManager.user?.displayName ?? Constants.userName)
                .font(.title2)
            
            Text(authManager.user?.email ?? Constants.userEmail)
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
                try await authManager.signOut()
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthManager())
}

//
//  AccountView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/26/24.
//

import SwiftUI

struct AccountView: View {
    @Environment(AuthManager.self) var authManger
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            switch authManger.authState {
            case .signedIn:
                AccountDetailView()
            case .signedOut:
                ProgressView()
            case .anonymous:
                LoginView()
            }
        }
    }
}

private struct AccountDetailView: View {
    @Environment(AuthManager.self) var authManger

    var body: some View {
        VStack {
            Spacer()
            if let displayName = authManger.user?.displayName {
                Text(displayName)
                    .font(.title2)
            }
            
            if let email = authManger.user?.email {
                Text(email)
                    .font(.title2)
            }
            Spacer()
            
            Button {
                Task {
                    authManger.signOut()
                }
            } label: {
                Text(UIStrings.signOut.localizedKey)
                    .defaultButton()
            }
        }
    }
}

//
//  EmailPasswordView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 5/23/25.
//

import SwiftUI

struct EmailPasswordView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage : String?
    
    var body: some View {
        VStack (spacing: 20) {
            TextField(UIStrings.email.localizedKey, text: $email)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            SecureField(UIStrings.password.localizedKey, text: $password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            Text(UIStrings.login.localizedKey)
                
        
        }
    }
}

#Preview {
    EmailPasswordView()
}

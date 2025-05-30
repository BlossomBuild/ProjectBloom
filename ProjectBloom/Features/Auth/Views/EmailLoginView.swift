//
//  EmailPasswordView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 5/23/25.
//

import SwiftUI

struct EmailLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage : String?
    
    var isEmailValid: Bool {
        return Constants.isValidEmail(for: email)
    }
    
    var isPasswordLongEnough: Bool {
        return Constants.isPasswordLongEnough(for: password)
    }
    
    var body: some View {
        VStack (spacing: 20) {
            TextField(UIStrings.email.localizedKey, text: $email)
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            SecureField(UIStrings.password.localizedKey, text: $password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
      
            
            Button {
                
            } label: {
                Text(UIStrings.login.localizedKey)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.bbWhite)
                    .background(email.isEmpty || password.isEmpty || !isEmailValid || !isPasswordLongEnough ? .gray : .bbGreen)
                    .clipShape(.rect(cornerRadius: 20))
                    .disabled(email.isEmpty || password.isEmpty || isEmailValid)
            }
            
            NavigationLink {
                EmailRegisterView()
            } label: {
                Text(UIStrings.register.localizedKey)
                    .foregroundStyle(.bbWhite)
            }
        }
    }
}

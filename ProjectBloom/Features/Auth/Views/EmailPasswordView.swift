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
    @State private var isRegistering: Bool = false
    
    var isEmailValid: Bool {
        let emailFormat =
        "^[A-Z0-9a-z._%+-]+@(?:[A-Z0-9a-z-]+\\.)+[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordLongEnough: Bool {
        password.count >= 8
    }

    var containsLetter: Bool {
        password.range(of: "[A-Za-z]", options: .regularExpression) != nil
    }

    var containsNumber: Bool {
        password.range(of: "\\d", options: .regularExpression) != nil
    }

    var containsSpecialCharacter: Bool {
        password.range(of: "[!@#$%^&*()_+=\\-{}|:;\"'<>,.?/~`]", options: .regularExpression) != nil
    }

    var isPasswordStrong: Bool {
        isPasswordLongEnough &&
        containsLetter &&
        containsNumber &&
        containsSpecialCharacter
    }
    
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
            
            
            if(isRegistering) {
                VStack(alignment: .leading) {
                    Text("• At least 8 characters")
                        .foregroundStyle(isPasswordLongEnough ? .bbWhite : .red)
                    Text("• Includes a letter")
                        .foregroundStyle(containsLetter ? .bbWhite : .red)
                    Text("• Includes a number")
                        .foregroundStyle(containsNumber ? .bbWhite : .red)
                    Text("• Includes a special character")
                        .foregroundStyle(containsSpecialCharacter ? .bbWhite : .red)
                }
            }
            
            Button {
                
            } label: {
                Text(!isRegistering ? UIStrings.login.localizedKey : UIStrings.register.localizedKey)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.bbWhite)
                    .background(email.isEmpty || password.isEmpty || !isEmailValid ? .gray : .bbGreen)
                    .clipShape(.rect(cornerRadius: 20))
                    .disabled(email.isEmpty || password.isEmpty || isEmailValid)
            }
            
            Button {
                isRegistering.toggle()
            } label: {
                Text(isRegistering ? UIStrings.login.localizedKey : UIStrings.register.localizedKey)
                    .foregroundStyle(.bbWhite)
            }
        }
    }
}

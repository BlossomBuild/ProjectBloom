//
//  EmailRegisterView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 5/29/25.
//

import SwiftUI

struct EmailRegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var errorMessage : String?
    
    var isEmailValid: Bool {
        Constants.isValidEmail(for: email)
    }
    
    var isPasswordLongEnough: Bool {
        Constants.isPasswordLongEnough(for: password)
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
    
    var passwordsMatch: Bool {
        !password.isEmpty && password == passwordConfirmation
    }
    
    var isPasswordStrong: Bool {
        isPasswordLongEnough &&
        containsLetter &&
        containsNumber &&
        containsSpecialCharacter
    }
    
    var body: some View {
        VStack (spacing: 16) {
            Spacer()
            
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
            
            SecureField(UIStrings.passwordConfirmation.localizedKey, text: $passwordConfirmation)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text("• Valid email")
                    .font(.subheadline.bold())
                    .foregroundStyle(isEmailValid ? .bbWhite : .red)
                Text("• Password At least 8 characters")
                    .foregroundStyle(isPasswordLongEnough ? .bbWhite : .red)
                Text("• Includes a letter")
                    .foregroundStyle(containsLetter ? .bbWhite : .red)
                Text("• Includes a number")
                    .foregroundStyle(containsNumber ? .bbWhite : .red)
                Text("• Includes a special character")
                    .foregroundStyle(containsSpecialCharacter ? .bbWhite : .red)
                Text("• Passwords Match")
                    .foregroundStyle(passwordsMatch ? .bbWhite : .red)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Text( UIStrings.register.localizedKey)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.bbWhite)
                    .background(email.isEmpty || password.isEmpty || !isEmailValid ? .gray : .bbGreen)
                    .clipShape(.rect(cornerRadius: 20))
                    .disabled(email.isEmpty || password.isEmpty || isEmailValid)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.bbGreenDark))
    }
}

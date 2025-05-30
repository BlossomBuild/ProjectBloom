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
    
    var isAbleToRegister: Bool {
        isPasswordStrong && isEmailValid && passwordsMatch
    }
    
    
    var body: some View {
        VStack (spacing: 20) {
            
            Spacer()
            
            TextField(UIStrings.email.localizedKey, text: $email)
                .textInputAutocapitalization(.never)
                .textContentType(.password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            SecureField(UIStrings.password.localizedKey, text: $password)
                .textContentType(.password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            SecureField(UIStrings.passwordConfirmation.localizedKey, text: $passwordConfirmation)
                .textContentType(.password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
                
            
            
            
            VStack(alignment: .leading, spacing: 5) {
                RegistrationRequirements(title: RegistrationRequirementsStrings.validEmail.localizedKey, criteria: isEmailValid)
                RegistrationRequirements(title: RegistrationRequirementsStrings.passwordLength.localizedKey, criteria: isPasswordLongEnough)
                RegistrationRequirements(title: RegistrationRequirementsStrings.letterRequirement.localizedKey, criteria: containsLetter)
                RegistrationRequirements(title: RegistrationRequirementsStrings.numberRequirement.localizedKey, criteria: containsNumber)
                RegistrationRequirements(title: RegistrationRequirementsStrings.specialCharacterRequirement.localizedKey, criteria: containsSpecialCharacter)
                RegistrationRequirements(title: RegistrationRequirementsStrings.passwordMatch.localizedKey, criteria: passwordsMatch)
            }
        
            Spacer()
            
            Button {
                
            } label: {
                Text( UIStrings.register.localizedKey)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.bbWhite)
                    .background(isAbleToRegister ? .bbGreen : .gray)
                    .clipShape(.rect(cornerRadius: 20))
                    .disabled(!isAbleToRegister)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.black))
    }
}


struct RegistrationRequirements: View {
    let title: LocalizedStringKey
    var criteria: Bool
    
    var body: some View {
        HStack {
            Image(systemName: Constants.bulletPointIcon)
                .resizable()
                .frame(width: 6, height: 6)
            
            Text(title)
        }
        .font(.subheadline)
        .bold()
        .foregroundStyle(.bbWhite)
        .strikethrough(criteria, color: .bbWhite)
    }
}


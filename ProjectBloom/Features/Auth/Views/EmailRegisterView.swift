//
//  EmailRegisterView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 5/29/25.
//

import SwiftUI

struct EmailRegisterView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var isPasswordVisible : Bool = false
    @State private var isConfirmPasswordVisible : Bool = false
    @State private var errorMessage : String?
    
    
    var isNameEmpty : Bool {
        name.isEmpty
    }
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
        isPasswordStrong && isEmailValid && passwordsMatch && !isNameEmpty
    }
    
    
    var body: some View {
        VStack (spacing: 20) {
            
            Spacer()
            
            TextField(UIStrings.name.localizedKey, text: $name)
                .textContentType(.password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            TextField(UIStrings.email.localizedKey, text: $email)
                .textInputAutocapitalization(.never)
                .textContentType(.password)
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            SecureInputField(text: $password, isVisible: $isPasswordVisible, placeholder: UIStrings.password.localizedKey)
            
            
            SecureInputField(text: $passwordConfirmation, isVisible: $isConfirmPasswordVisible, placeholder: UIStrings.passwordConfirmation.localizedKey)
            
            VStack(alignment: .leading, spacing: 5) {
                RegistrationRequirements(title: RegistrationRequirementsStrings.validName.localizedKey, criteria: !isNameEmpty)
                RegistrationRequirements(title: RegistrationRequirementsStrings.validEmail.localizedKey, criteria: isEmailValid)
                RegistrationRequirements(title: RegistrationRequirementsStrings.passwordLength.localizedKey, criteria: isPasswordLongEnough)
                RegistrationRequirements(title: RegistrationRequirementsStrings.letterRequirement.localizedKey, criteria: containsLetter)
                RegistrationRequirements(title: RegistrationRequirementsStrings.numberRequirement.localizedKey, criteria: containsNumber)
                RegistrationRequirements(title: RegistrationRequirementsStrings.specialCharacterRequirement.localizedKey, criteria: containsSpecialCharacter)
                RegistrationRequirements(title: RegistrationRequirementsStrings.passwordMatch.localizedKey, criteria: passwordsMatch)
            }
        
            Spacer()
            
            Button {
                Task {
                    authViewModel.registerUser(email: email, password: password, userName: name)
                }
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
        .overlay {
            if authViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
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

struct SecureInputField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    var placeholder: LocalizedStringKey


    var body: some View {
        ZStack {
            if isVisible {
                TextField(placeholder, text: $text)
                    .textContentType(.password)
                    .foregroundStyle(.white)
            } else {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            HStack {
                Spacer()
                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? Constants.hidePasswordIcon : Constants.showPasswordIcon)
                        .foregroundStyle(.gray)
                }
                .padding(.trailing, 12)
            }
        }
    }
}


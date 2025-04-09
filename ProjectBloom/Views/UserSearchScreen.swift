//
//  UserSearchScreen.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/9/25.
//

import SwiftUI

struct UserSearchScreen: View {
    @State private var searchText: String = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.magnifyingGlassIcon)
                    .foregroundStyle(.gray)
                    .font(.system(size: 20))
                
                TextField(Constants.searchByEmail, text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal)
        }
    }
}

#Preview {
    UserSearchScreen()
}







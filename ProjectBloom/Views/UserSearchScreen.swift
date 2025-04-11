//
//  UserSearchScreen.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/9/25.
//

import SwiftUI

struct UserSearchScreen: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @State var searchText: String = ""
    
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
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
                .padding(.top, 20)
                
                ForEach(databaseViewModel.userDetailsSearch) { userDetails in
                    UserSearchItem(userDetails: userDetails)
                }
                .padding(10)
            }
        }
        .task(id: searchText) {
            try? await Task.sleep(for: .seconds(0.5))
            if Task.isCancelled {
                return
            }
            await databaseViewModel.searchUsersByEmail(userEmail: searchText)
        }
    }
}







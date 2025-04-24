//
//  UserSearchScreen.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/9/25.
//

import SwiftUI

struct UserSearchScreen: View {
    @Environment(DatabaseViewModel.self) var databaseViewModel
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    let currenProject: Project
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        Image(systemName: Constants.magnifyingGlassIcon)
                            .foregroundStyle(.gray)
                            .font(.system(size: 20))
                        
                        TextField(UIStrings.searchByEmail.string, text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    switch databaseViewModel.userSearchStatus {
                    case .success:
                        if databaseViewModel.userDetailsSearch.isEmpty {
                            Text(UIStrings.noResultsFound.localizedKey)
                                .frame(width: geo.size.width, height: geo.size.height)
                        } else {
                            ForEach(databaseViewModel.userDetailsSearch) { userDetails in
                                UserSearchItem(userDetails: userDetails)
                                    .onTapGesture {
                                        addUser(userDetails: userDetails)
                                        dismiss()
                                    }
                            }
                            .padding(.leading, 20)
                            .padding(.top, 10)
                        }
                    case .failed:
                        Text(UIStrings.genericErrorMessage.localizedKey)
                            .frame(width: geo.size.width, height: geo.size.height)
                    case .notStarted:
                        EmptyView()
                    case .fetching:
                        ProgressView()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
        }
        .task(id: searchText) {
            try? await Task.sleep(for: .seconds(0.5))
            if Task.isCancelled {
                return
            }
            await databaseViewModel.searchUsersByEmail(project: currenProject,userEmail: searchText)
        }
        .onAppear {
            searchText = ""
            databaseViewModel.userDetailsSearch = []
        }
    }
    
    func addUser(userDetails: UserDetails){
        Task {
            do {
                try await DatabaseManager.shared.addUserToProject(
                    project: currenProject,
                    userDetails: userDetails
                )
                
                databaseViewModel.appendUserEmailToProject(
                    email: userDetails.userEmail.lowercased(),
                    toProjectID: currenProject.id
                )
            }
        }
    }
}







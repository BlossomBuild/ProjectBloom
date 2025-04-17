//
//  UserSearchItem.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 4/11/25.
//

import SwiftUI

struct UserSearchItem: View {
    var userDetails: UserDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(userDetails.userName)
                .font(.headline)
            Text(userDetails.userEmail)
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            Divider()
        }
    }
}

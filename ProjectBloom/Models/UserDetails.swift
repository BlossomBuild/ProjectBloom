//
//  UserDetails.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/3/24.
//

import Foundation


struct UserDetails: Identifiable, Codable {
    var id: String
    var userName: String
    var userEmail: String
    
    static var userSample1: UserDetails {
        UserDetails(id: SampleData.sampleUser1ID.rawValue, userName: SampleData.sampleUser1Name.rawValue, userEmail: SampleData.sampleUser1Email.rawValue)
    }
}



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
    
    static var userSample2: UserDetails {
        UserDetails(id: SampleData.sampleUser2ID.rawValue, userName: SampleData.sampleUser2Name.rawValue, userEmail: SampleData.sampleUser2Email.rawValue)
    }
    
    static var userSample3: UserDetails {
        UserDetails(id: SampleData.sampleUser3ID.rawValue, userName: SampleData.sampleUser3Name.rawValue, userEmail: SampleData.sampleUser3Email.rawValue)
    }
    
    static var userSample4: UserDetails {
        UserDetails(id: SampleData.sampleUser4ID.rawValue, userName: SampleData.sampleUser4Name.rawValue, userEmail: SampleData.sampleUser4Email.rawValue)
    }
}



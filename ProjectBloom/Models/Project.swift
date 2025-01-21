//
//  ProjectDetails.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/5/24.
//

import Foundation

struct Project: Identifiable, Codable, Sendable {
    var id = UUID()
    var name: String
    var projectLeaderID: String
    var usersID: [String]
    var usersDetails: [UserDetails]

    
    static var sampleProjects = [
        Project(name: "Project 1", projectLeaderID: SampleData.sampleUser1ID.rawValue, usersID: ["123"], usersDetails: [UserDetails(id: "1", userName: "Example User 1", userEmail: "example1@gmail.com")] ),
        Project(name: "Project 2", projectLeaderID: "1234567890", usersID: ["1234"], usersDetails: [UserDetails(id: "2", userName: "Example User 2", userEmail: "example2@gmail.com")] )
    ]
    
}



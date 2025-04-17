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
}



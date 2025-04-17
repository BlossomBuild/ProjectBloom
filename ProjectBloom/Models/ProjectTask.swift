//
//  UserTask.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 12/10/24.
//

import Foundation
import FirebaseFirestore

struct ProjectTask: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var assignedToID: String
    var assignedToUserName: String
    var isActiveTask: Bool
    var description: String?
    var completedAt: Timestamp?
    var isCompleted: Bool?
}




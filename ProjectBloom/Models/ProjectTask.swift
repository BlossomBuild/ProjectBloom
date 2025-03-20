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
    
    static let sampleProjectTasks: [ProjectTask] = [
        ProjectTask(title: "Project Task 1", assignedToID: SampleData.sampleUser1ID.rawValue, assignedToUserName: SampleData.sampleUser1Name.rawValue, isActiveTask: false),
        ProjectTask(title: "Project Task 2", assignedToID: SampleData.sampleUser1ID.rawValue, assignedToUserName: SampleData.sampleUser1Name.rawValue, isActiveTask: true)
    ]
    
    static let sampleProjectTasksEmpty: [ProjectTask] = [
    ]
}




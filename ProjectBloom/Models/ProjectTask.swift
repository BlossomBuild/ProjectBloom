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
    var description: String
    var assignedToID: String
    var assignedToUserName: String
    var isActiveTask: Bool
    var completedAt: Timestamp?
    var completedByID: String?
    
    static let sampleProjectTasks: [ProjectTask] = [
        ProjectTask(title: "Project Task 1", description: "Description 1", assignedToID: SampleData.sampleUser1ID.rawValue, assignedToUserName: SampleData.sampleUser1Name.rawValue, isActiveTask: false),
        ProjectTask(title: "Project Task 2", description: "Description 2", assignedToID: SampleData.sampleUser1ID.rawValue, assignedToUserName: SampleData.sampleUser1Name.rawValue, isActiveTask: true),
        ProjectTask(title: "Project Task 3", description: "Description 3", assignedToID: SampleData.sampleUser2ID.rawValue, assignedToUserName: SampleData.sampleUser2Name.rawValue, isActiveTask: false),
        ProjectTask(title: "Project Task 4", description: "Description 4", assignedToID: SampleData.sampleUser2ID.rawValue, assignedToUserName: SampleData.sampleUser2Name.rawValue, isActiveTask: true),
        ProjectTask(title: "Project Task 5", description: "Description 5", assignedToID: SampleData.sampleUser3ID.rawValue, assignedToUserName: SampleData.sampleUser3Name.rawValue, isActiveTask: false),
        ProjectTask(title: "Project Task 6", description: "Description 6", assignedToID: SampleData.sampleUser3ID.rawValue, assignedToUserName: SampleData.sampleUser3Name.rawValue, isActiveTask: true)
    ]
    
    static let sampleProjectTasksEmpty: [ProjectTask] = [
    ]
    
    
    func formatDate(timeStamp: Timestamp?) -> String {
        guard let completedAt = timeStamp?.dateValue() else { return "" }
             let formatter = DateFormatter()
             formatter.dateFormat = "MM/dd/yyyy"
             return formatter.string(from: completedAt)
         }
}




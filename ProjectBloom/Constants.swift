//
//  Constants.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/22/24.
//

import Foundation
import SwiftUI

struct Constants {
    //MARK: UI Strings
    static var appName = "Project Bloom"
    static var skipString = "Skip"
    static var signOutString = "Sign Out"
    static var projectNameString = "Project Name"
    static var cancelString = "Cancel"
    static var createString = "Create"
    static var renameString = "Rename"
    static var updateString = "Update"
    static var completeString = "Complete"
    static var taskString = "Task"
    static var completedTasksString = "Completed Tasks"
    static var spaceString = " "
    static var colonString = ":"
    static var completedByString = "Completed By"
    static var completeOnString = "Completed On"
    static var taskNameString = "Task Name"
    static var projectsString = "Projects"
    static var undoString = "Undo"
    static var taskDeletedString = "Task Deleted"
    
    //MARK: UI Icons
    static var signedInImage = "person.crop.circle.badge.checkmark"
    static var signedOutImage = "person.crop.circle.badge.questionmark"
    static var addProjectImage = "document.badge.plus.fill"
    static var editIcon = "pencil"
    static var checkmarkIcon = "checkmark"
    static var clipboardIcon = "list.bullet.clipboard"
    static var trashIcon = "trash"
    
    //MARK: UI Unwraps
    static var userName = "User Name"
    static var userEmail = "User Email"
}

enum DefaultTaskStrings: String {
    case userHasNoTasksAssigned = "User has no tasks assigned"
    case defaultTaskTitle = "No task assigned"
    case defaultTaskDescription = ""
    
}

enum SampleData: String {
    case sampleUser1ID = "sampleUser1ID"
    case sampleUser1Name = "Sample User 1"
    case sampleUser1Email = "sampleUser1@email.com"
    
    case sampleUser2ID = "sampleUser2ID"
    case sampleUser2Name = "Sample User 2"
    case sampleUser2Email = "sampleUser2@email.com"
    
    case sampleUser3ID = "sampleUser3ID"
    case sampleUser3Name = "Sample User 3"
    case sampleUser3Email = "sampleUser3@email.com"
    
    case sampleUser4ID = "sampleUser4ID"
    case sampleUser4Name = "Sample User 4"
    case sampleUser4Email = "sampleUser4@email.com"
    
}

enum FirebasePaths: String {
    case projects = "projects"
    case userDetails = "userDetails"
    case usersID = "usersID"
    case projectTasks = "projectTasks"
    case completedTasks = "completedTasks"
 }

extension Text {
    func ghostButton(borderColor: Color) -> some View {
        self
            .frame(width: 100, height: 50)
            .foregroundStyle(.buttonText)
            .bold()
            .background(alignment: .center) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(borderColor,lineWidth: 5)
            }
    }
}

extension Font {
    static let poppinsFontBold = Font.custom("Poppins-Bold", size: 30)
    static let poppinsFontRegular = Font.custom("Poppins-Regular", size: 25)
}




//Tried to use this way for swifui to change the nav bar color
//                .toolbarBackground(.bbGreen, for: .navigationBar)
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarColorScheme(.dark, for: .navigationBar)

//
//  Constants.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 11/22/24.
//

import Foundation
import SwiftUI

struct Constants {
    //MARK: UI Icons
    static var signedInIcon = "person.crop.circle.badge.checkmark"
    static var signedOutIcon = "person.crop.circle.badge.questionmark"
    static var addProjectImage = "document.badge.plus.fill"
    static var editIcon = "pencil"
    static var pencilIcon = "pencil.circle.fill"
    static var trashIcon = "trash"
    static var activeTaskIcon = "list.bullet.clipboard"
    static var completeTaskIcon = "clipboard.fill"
    static var arrowUpIcon = "arrow.up.circle.fill"
    static var checkMarkIcon = "checkmark.circle.fill"
    static var addUser = "person.badge.plus"
    static var magnifyingGlassIcon = "magnifyingglass"
    
    //MARK: UI Unwraps
    static var userName = "User Name"
    static var userEmail = "User Email"
    
    //MARK: Constant Functions
    static func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        return switch hour {
        case 6..<12: GreetingStrings.goodMorning.rawValue
        case 12..<18: GreetingStrings.goodAfternoon.rawValue
        case 18..<24: GreetingStrings.goodEvening.rawValue
        default: GreetingStrings.hello.rawValue
        }
    }
    
    static func getFormattedDate(projectTask: ProjectTask) -> String {
        guard let completedAt = projectTask.completedAt?.dateValue() else {return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: completedAt)
    }
    
    static func getFirstName(from fullName: String?) -> String {
        fullName?.components(separatedBy: " ").first ?? ""
    }
}

enum UIStrings: String {
    case appName = "Project Bloom"
    case activeTasks = "Active Tasks"
    case cancel = "Cancel"
    case completedBy = "Completed By"
    case completedTasks = "Completed Tasks"
    case create = "Create"
    case delete = "Delete"
    case descriptionOptional = "Description (Optional)"
    case projects = "Projects"
    case projectName = "Project Name"
    case rename = "Rename"
    case searchByEmail = "Search by Email"
    case signOut = "Sign Out"
    case skip = "Skip"
}

enum MessageStrings: String {
    case loadingUserInfo = "Loading User Info..."
    case noActiveProjects = "No Active Projects"
    case noCompletedTasks = "No Completed Tasks"
    case noResultsFound = "No Results Found"
    case signingOut = "Signing Out..."
}

enum GreetingStrings: String {
    case goodMorning = "Good Morning"
    case goodAfternoon = "Good Afternoon"
    case goodEvening = "Good Evening"
    case hello = "Hello"
    
}

enum Punctuation: String {
    case colon = ":"
    case comma = ","
    case space = " "
}

enum AlertString: String {
    case actionCantBeUndone = "This action can't be undone"
}

enum DefaultTaskStrings: String {
    case userHasNoTasksAssigned = "User has no tasks assigned"
    case defaultTaskTitle = "No task assigned"
    case defaultTaskDescription = ""
    
}

enum UserErrorMessages: String {
    case deletingProjectError = "Error deleting project please try again"
    case genericErrorMessage = "Something went wrong please try again"
}

enum FirebasePaths: String {
    case projects = "projects"
    case userDetails = "userDetails"
    case userEmails = "userEmails"
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

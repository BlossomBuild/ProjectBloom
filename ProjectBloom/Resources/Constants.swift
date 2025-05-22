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
    static var appleLogo = "apple.logo"
    static var signedInIcon = "person.crop.circle.badge.checkmark"
    static var signedOutIcon = "person.crop.circle.badge.questionmark"
    static var addProjectImage = "document.badge.plus.fill"
    static var editIcon = "pencil"
    static var emailIcon = "envelope"
    static var pencilIcon = "pencil.circle.fill"
    static var trashIcon = "trash"
    static var activeTaskIcon = "list.bullet.clipboard"
    static var completeTaskIcon = "clipboard.fill"
    static var arrowUpIcon = "arrow.up.circle.fill"
    static var checkMarkIcon = "checkmark.circle.fill"
    static var addUser = "person.badge.plus"
    static var magnifyingGlassIcon = "magnifyingglass"
    static var removeUserIcon = "minus.circle"
    static var google = "google"
    
    //MARK: Constant Functions
    static func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        return switch hour {
        case 0..<12: GreetingStrings.goodMorning.string
        case 12..<18: GreetingStrings.goodAfternoon.string
        case 18..<24: GreetingStrings.goodEvening.string
        default: GreetingStrings.hello.string
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
    
    static func isProjectLeader(leaderID: String, currentUserID: String) -> Bool {
        return leaderID == currentUserID
    }
    
    static func taskOwner(taskOwnerID: String, currentUserID: String) -> Bool {
        return taskOwnerID == currentUserID
    }
    
}

enum UIStrings: String {
    case appName = "app_name"
    case activeTasks = "active_tasks"
    case cancel = "cancel"
    case completedBy = "completed_by"
    case completedTasks = "completed_tasks"
    case continueAnonymously = "continue_anonymously"
    case continueWithApple = "continue_with_apple"
    case continueWithEmail = "continue_with_email"
    case continueWithGoogle = "continue_with_google"
    case create = "create"
    case delete = "delete"
    case deleteProjectError = "delete_project_error"
    case descriptionOptional = "description_optional"
    case genericErrorMessage = "generic_error_message"
    case irreversibleAction = "irreversible_action"
    case noActiveProjects = "no_active_projects"
    case noCompletedTasks = "no_completed_tasks"
    case noResultsFound = "no_results_found"
    case projects = "projects"
    case projectName = "project_name"
    case remove = "remove"
    case removeUserError = "remove_user_error"
    case removeUserMessage = "remove_user_message"
    case rename = "rename"
    case searchByEmail = "search_by_email"
    case signingOut = "signing_out"
    case signOut = "sign_out"
    case skip = "skip"
    case userEmail = "user_email"
    case userName = "user_name"
}

extension UIStrings {
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
    
    var string: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum Punctuation: String {
    case colon = "colon"
    case comma = "comma"
    case space = "space"
    case questionMark = "question_mark"
}

extension Punctuation {
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

enum GreetingStrings: String {
    case goodMorning = "good_morning"
    case goodAfternoon = "good_afternoon"
    case goodEvening = "good_evening"
    case hello = "hello"
}

extension GreetingStrings {
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
    
    var string: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum DefaultTaskStrings: String {
    case userHasNoTasksAssigned = "User has no tasks assigned"
    case defaultTaskTitle = "No task assigned"
    case defaultTaskDescription = ""
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
    static let poppinsFontBold = Font.custom("Poppins-Bold", size: 35)
    static let poppinsFontRegular = Font.custom("Poppins-Regular", size: 25)
}






//Tried to use this way for swifui to change the nav bar color
//                .toolbarBackground(.bbGreen, for: .navigationBar)
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarColorScheme(.dark, for: .navigationBar)

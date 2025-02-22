Firebase Setup Guide

1. Add Firebase Configuration
Download the GoogleService-Info.plist file from the Firebase Console.
Add it to your Xcode project.
Install the Firebase SDK using Swift Package Manager (SPM) or CocoaPods.

2. Enable Authentication
In the Firebase Console, enable Google Sign-In and Anonymous Sign-In under Authentication > Sign-in method.

3. Configure Firestore Security Rules
Update your Firestore security rules to restrict access to authenticated users:

rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}

This ensures that only authenticated users can read and write data.

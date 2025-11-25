# LabTrack - Laboratory Equipment Borrowing App

A Flutter-based mobile application designed to streamline the process of borrowing and returning laboratory equipment for students and staff.

## Key Features

-   **User Authentication**: Secure login for students and staff using Firebase Authentication.
-   **Item Borrowing**: Students can browse available lab items, add them to a cart, and submit borrow requests.
-   **Transaction History**: View a consolidated history of all past borrow and return transactions.
-   **Penalty Management**: Automatically tracks and displays penalties for overdue or damaged items.
-   **Item Reporting**: Students can report damaged or lost items directly through the app.
-   **Personalized Dashboards**: Separate, role-based dashboards for Students and Staff.
-   **Staff-Side Management**: Staff can view all active transactions and process returns (partially or completely).

## Architecture Overview

This project follows a **Model-View-Controller (MVC)** architecture to ensure a clean separation of concerns, making the codebase maintainable and scalable.

-   **Model**: (`lib/student/models/`)
    -   Contains plain Dart objects (e.g., `BorrowTransaction`, `UserModel`, `LabItem`).
    -   Responsible for representing the data structure and includes `fromFirestore` and `toJson` methods for serialization with Firebase.

-   **View**: (`lib/student/views/`, `lib/staff/views/`)
    -   Comprises Flutter widgets responsible for the UI.
    -   Contains minimal to no business logic. It captures user input and delegates actions to the controller.

-   **Controller**: (`lib/student/controllers/`, `lib/staff/controllers/`)
    -   Acts as the "brain" for each view.
    -   Handles user input from the View, executes business logic, manages state, and interacts with the Service layer to fetch or push data.

-   **Services**: (`lib/student/services/`)
    -   An abstraction layer for all external dependencies.
    -   `DatabaseService` encapsulates all Cloud Firestore queries and mutations.
    -   `AuthService` handles all Firebase Authentication logic.

## Technology Stack

-   **Framework**: Flutter
-   **Language**: Dart
-   **Database**: Cloud Firestore
-   **Authentication**: Firebase Authentication

## Project Structure

The codebase is organized by feature and role, primarily under the `student` and `staff` directories.

```
lib/
├── student/
│   ├── controllers/    # Business logic for student views
│   ├── models/         # Data structures (e.g., UserModel)
│   ├── services/       # Firebase interactions (Auth & DB)
│   └── views/          # UI Widget screens
├── staff/
│   ├── controllers/    # Business logic for staff views
│   └── views/          # UI Widget screens
├── widgets/            # Reusable widgets (e.g., CommonAppBar)
└── main.dart           # App entry point and route definitions
```

## Getting Started

Follow these instructions to get the project running on your local machine.

### Prerequisites

-   Flutter SDK (v3.0 or higher)
-   An IDE such as VS Code or Android Studio

### Firebase Setup

1.  Create a new project on the [Firebase Console](https://console.firebase.google.com/).
2.  Add a new Android or iOS app to your Firebase project. Follow the on-screen instructions to register your app.
3.  Download the configuration file (`google-services.json` for Android or `GoogleService-Info.plist` for iOS) and place it in the appropriate directory (`android/app/` or `ios/Runner/`).
4.  In the Firebase console, enable the following services:
    -   **Authentication**: Enable the "Email/Password" sign-in method.
    -   **Cloud Firestore**: Create a new database. Start in "test mode" for initial development.
5.  **Populate Data**: Use the provided `.txt` files as a reference to manually create and populate the necessary collections in your Firestore database (e.g., `users`, `lab_items`, `borrow_transactions`, etc.).

### Run the App

1.  Clone the repository:
    ```sh
    git clone <repository-url>
    ```
2.  Navigate to the project directory:
    ```sh
    cd labtrack-project
    ```
3.  Install dependencies:
    ```sh
    flutter pub get
    ```
4.  Run the application:
    ```sh
    flutter run
    ```

## Firestore Data Model

The application relies on a set of core collections in Firestore:

-   `users`: Stores user profile information, including their role (student/staff).
-   `lab_items`: Contains the inventory of all available laboratory items and their stock counts.
-   `borrow_transactions`: Records all active borrowing transactions, linking users to the items they've borrowed.
-   `return_items`: A log of all completed or partial return events.
-   `penalties`: Tracks any penalties assigned to users.
-   `reported_items`, `request_items`, `waitlist_items`: Collections to manage other user-specific states.
-   `courses`: A list of academic courses for associating with transactions.

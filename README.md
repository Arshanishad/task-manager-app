# Task Manager

A Flutter Task Manager application built with **Flutter, Riverpod, Firebase Cloud Firestore, Hive, and Connectivity Plus**.

The app supports complete task management with **offline-first local storage** and automatic synchronization with Firestore when an internet connection is available.

## Features

### Task Management

- Create tasks
- Edit tasks
- Delete tasks
- Mark tasks as completed/uncompleted
- View task details
- Task title and description
- Task priority
- Task due date
- Task created date

### Search, Filter & Sort

- Search tasks by title
- Filter by:
  - All
  - Completed
  - Pending
- Sort by:
  - Due Date
  - Priority

### Offline Support

- Tasks are stored locally using Hive
- Tasks can be created and updated without internet
- Changes are marked for synchronization
- Automatically syncs with Firestore when internet becomes available
- Displays Online/Offline status
- Local data remains available when offline

### Firebase

- Firebase Cloud Firestore for remote task storage
- Automatic synchronization between local storage and Firestore

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application framework |
| Dart | Programming language |
| Riverpod | State management |
| Hive | Local/offline database |
| Firebase Firestore | Cloud database |
| Connectivity Plus | Internet connectivity detection |
| UUID | Unique task IDs |
| Intl | Date formatting |

## Architecture

The project follows a **feature-based architecture**:

```text
lib/
│
├── main.dart
├── firebase_options.dart
│
├── core/
│   └── providers/
│       └── providers.dart
│
└── features/
    └── task/
        │
        ├── data/
        │   ├── local/
        │   │   └── task_local_data_source.dart
        │   │
        │   ├── remote/
        │   │   └── task_remote_datasource.dart
        │   │
        │   └── repository/
        │       └── task_repository.dart
        │
        ├── models/
        │   └── task_model.dart
        │
        ├── providers/
        │   └── task_provider.dart
        │
        └── screens/
            ├── task_list_screen.dart
            ├── add_edit_task_screen.dart
            └── task_details_screen.dart

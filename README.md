# 🧠 Flodo Task Management App

A clean, production-quality Flutter task manager built as part of the Flodo AI take-home assignment.

---

## 🚀 Features

### ✅ Core Features

* **Task Model**

  * Title
  * Description
  * Due Date
  * Status (To-Do, In Progress, Done)
  * Blocked By (dependency support)

* **CRUD Operations**

  * Create tasks
  * Read/list tasks
  * Update task status
  * Delete (optional if implemented)

* **Search & Filter**

  * Real-time search by title
  * Filter by task status
  * Combined filtering supported

* **Blocked Task Logic**

  * Tasks depending on others are:

    * Greyed out
    * Disabled (non-interactive)
    * Clearly labeled ("Blocked by: X")
  * Automatically unblocked when dependency is completed

* **Draft Persistence**

  * Form data is saved automatically
  * Restored when user returns to the screen

* **Async UX Handling**

  * Simulated 2-second delay for create/update
  * Loading indicator shown
  * Prevents duplicate submissions

---

## 🧱 Tech Stack

* **Flutter (Dart)**
* **State Management:** Riverpod
* **Database:** Isar (local database)
* **Persistence:** SharedPreferences (draft feature)

---

## 🏗️ Architecture

* Clean separation of concerns:

  * `models/` → Data models (Task)
  * `providers/` → State management (Riverpod)
  * `screens/` → UI screens
* Derived state used for search + filtering
* Dependency-aware UI logic implemented cleanly

---

## 🎨 UI/UX Highlights

* Material 3 design
* Card-based layout
* Status color indicators
* Disabled UI for blocked tasks
* Responsive and clean spacing

---

## ⚙️ Setup Instructions

1. Clone the repository:

```bash
git clone <your-repo-link>
cd task_manager_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run code generation (Isar):

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:

```bash
flutter run
```

---

## 🧪 How to Test Key Features

### Blocked Logic

* Create Task A
* Create Task B blocked by Task A
* Task B should be disabled
* Mark Task A as "Done"
* Task B becomes active

### Draft Persistence

* Start creating a task
* Navigate away
* Return → data should be restored

---

## 🤖 AI Usage Report

AI tools (ChatGPT) were used to:

* Accelerate Riverpod architecture setup
* Resolve Isar integration issues
* Improve UI/UX structure

Example issue:

* AI initially suggested incorrect Isar setup for web compatibility
* Fixed by switching to supported configuration and testing locally

---

## 🎥 Demo Video

https://drive.google.com/file/d/1HGeazTr64Ju8iyY2k33kZPm8VqV3NEh0/view?usp=sharing

---

## 📌 Track Selection

**Track B — Mobile Specialist**

Focus:

* High-quality UI/UX
* Local database (Isar)
* Smooth state management

---

## 💡 Key Technical Decision

Used **derived state with Riverpod** (`filteredTasksProvider`) instead of filtering inside UI.

This ensures:

* Clean architecture
* Better performance
* Scalable logic

---

## ✅ Status

✔ All core requirements completed
✔ UI polished
✔ Edge cases handled

---

## 🙌 Thank You

Looking forward to your feedback!

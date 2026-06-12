# Implementation Plan: Offline-First Gym Tracking Application (Flutter)

This document outlines the architecture, database schema, core feature mechanics, and a phased development roadmap for building a robust, offline-first gym logger and progress tracker in Flutter (V1).

---

## 1. Tech Stack & Core Architecture

### High-Level Architecture
To achieve a completely seamless offline experience with zero load times or network dependency, the app will utilize a local-first database architecture. State management will control user input, timer events, and real-time computation (e.g., One-Rep Max, Plate Calculator).

* **Framework:** Flutter (Dart)
* **Local Database:** **Isar Database** or **Drift (Moor)**
  * *Why:* Both provide exceptional performance for relational data structures (Routines ➔ Workouts ➔ Exercises ➔ Sets) compared to basic SQLite, offering type safety, reactive streams, and fast read/writes.
* **State Management:** **Riverpod** or **BLoC**
  * *Why:* Essential for managing complex interactive states like active workout sessions, background rest timers, and live performance metrics tracking.
* **Local Notifications:** `flutter_local_notifications` (for notifying the user when the rest timer expires while the app is in the background).

---

## 2. Database Schema (Entities & Relationships)

Because the application tracks deeply interconnected lifting data, a relational-style NoSQL or SQL setup is required. Below is the relational structure designed for Isar/Drift:

```
+--------------------+        +--------------------+        +---------------------+
|      Exercise      |        |  WorkoutTemplate   |        |   WorkoutSession    |
+--------------------+        +--------------------+        +---------------------+
| id (Int/UUID)      |        | id (Int/UUID)      |        | id (Int/UUID)       |
| name (String)      |        | name (String)      |        | templateId (Int, FK)|
| description (Text) | 1    N | description (Text) | 1    N | name (String)       |
| targetMuscle (Enum)|--------| targetMuscle (Enum)|--------| startTime (DateTime)|
| equipment (Enum)   |        | createdBy (Enum)   |        | endTime (DateTime)  |
| isCustom (Bool)    |        +--------------------+        | notes (Text)        |
+--------------------+                                      +---------------------+
          | 1                                                          | 1
          |                                                            |
          +----------------------------+   +---------------------------+
                                       |   |
                                       v   v
                            +---------------------+
                            |     ExerciseSet     |
                            +---------------------+
                            | id (Int/UUID)       |
                            | sessionId (Int, FK) |
                            | exerciseId (Int, FK)|
                            | weight (Double)     |
                            | reps (Int)          |
                            | setType (Enum)      | 
                            | restTime (Int, sec) |
                            | isCompleted (Bool)  |
                            | timestamp (DateTime)|
                            +---------------------+
```

### Key Enums:
* `TargetMuscle`: Chest, Back, Quads, Hamstrings, Shoulders, Biceps, Triceps, Abs, Calves, FullBody.
* `Equipment`: Barbell, Dumbbell, Machine, Cables, Bodyweight, SmithMachine.
* `SetType`: Normal, Warmup, DropSet, Failure.

---

## 3. Core Feature Implementation Mechanics

### 3.1. "Make a Gym Program for Me" (Offline Rule-Engine)
Since V1 is completely offline, program generation relies on a built-in static rule mapping rather than remote AI processing.

1. **Questionnaire Flow (UI):**
   * Days available per week (2, 3, 4, 5)
   * Primary goal (Hypertrophy / Strength / General Fitness)
   * Available equipment (Full Gym / Home Gym / Dumbbells Only)
2. **Logic Processing (Local Assets):**
   * Pre-program standard routines (e.g., 3-Day Push/Pull/Legs, 4-Day Upper/Lower, 3-Day Full Body) into the app's initial asset data (`assets/programs.json`).
   * Match user inputs directly to the closest JSON template profile.
   * Upon confirmation, cloning the template objects directly into the local database under `WorkoutTemplate` records.

### 3.2. Tracking Progressive Overload & Logger UI
To ensure the user is constantly pushing for progress, the logger screen must dynamically feed past information forward.

* **"Last Time" Micro-Previews:** Inside the input field row for Set N, query the local database for the *most recent* `ExerciseSet` for that specific `exerciseId` belonging to a completed `WorkoutSession`. Display a light grey placeholder: `Last: 185 lbs x 8`.
* **Estimated 1RM (One Rep Max):** Calculate 1RM instantly on set completion using the Brzycki Formula: 
  $$	ext{1RM} = rac{	ext{Weight}}{1.0278 - (0.0278 	imes 	ext{Reps})}$$
  Store or dynamically calculate this values to populate long-term historical charts.

### 3.3. Automatic Rest Timer
* **Trigger:** When a user checks the `isCompleted` checkbox for any given `ExerciseSet`, a local timer is initialized.
* **Duration Configuration:** Pull the default rest time mapped to the `Exercise` or `WorkoutTemplate` (e.g., 90 seconds). Provide standard floating action buttons to add or subtract 30 seconds instantly.
* **Background Handling:** Use a simple stopwatch stream in state management. If the app goes to the background, compute the exact target epoch time. Trigger a local notification via `flutter_local_notifications` precisely when the current time reaches the target epoch.

### 3.4. Plate Calculator Component
* **Logic:** Provide a micro-overlay utility helper. Given a targeted weight $W$ and a standard bar weight $B$ (default 45 lbs or 20 kg):
  $$	ext{Weight per side} = rac{W - B}{2}$$
* **Greedy Algorithm:** Iterate through available plate metrics (e.g., 45, 35, 25, 10, 5, 2.5) to determine the exact count of each plate required on one side of the bar.

### 3.5. Local Backup & Restore (JSON/CSV)
* **Export:** Serialize all database tables into a uniform nested JSON configuration object. Write this file to local app storage documents directory using `path_provider` and expose it via the native sharing sheet (`share_plus`) so users can export it to Files, Google Drive, or iCloud.
* **Import:** Accept a `.json` file upload, parse and validate the internal key-value schemas, clear existing tables (or merge based on UUID uniqueness), and re-populate the local database.

---

## 4. Phased Implementation Roadmap

### Phase 1: Local Foundation & Seed Database (Weeks 1-2)
* Setup Flutter boilerplate with chosen state management and `Isar`/`Drift`.
* Define schemas for `Exercise`, `WorkoutTemplate`, `WorkoutSession`, and `ExerciseSet`.
* Pre-seed the local DB with a full dictionary of standard exercises (over 100+ standard moves containing targeted muscles, instructions, and correct machine selections).
* Build UI for browsing, filtering, and creating custom exercises.

### Phase 2: Active Logger & Automatic Timer (Weeks 3-4)
* Design the Core Workout Session tracking UI (rendering exercises, adding sets, mutating weight/reps counters).
* Implement state management to capture live session data.
* Build the automatic rest timer logic, incorporating floating countdown banners and background execution with local push alerts.

### Phase 3: Progressive Overload & Metrics Engines (Week 5)
* Implement the "Last Time" historical set reader inside the logging view.
* Write localized algorithms for calculating Estimated 1RM, Volume ($W 	imes R$), and Plate calculations.
* Build out the onboarding questionnaire rule-engine to automatically populate workout routines from internal static program data.

### Phase 4: History Analytics & File Backup (Week 6)
* Create historical logging list screens showing full past performance breakdowns.
* Construct analytical visual dashboards utilizing `fl_chart` to render progress lines for estimated 1RM, workout frequency, and targeted muscle distributions over time.
* Add backup utilities enabling JSON importing and exporting capabilities to preserve storage data.

### Phase 5: Polishing & Edge Cases (Week 7)
* Ensure graceful handling of incomplete workout states (e.g., app crashes mid-workout, saving progress automatically).
* Run profile tests on database queries to ensure smooth UI performance during large history scales.
* Finalize internal visual styling elements.

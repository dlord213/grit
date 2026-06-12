# Grit Gym Tracker

Grit is a modern, offline-first, premium gym tracking application built with Flutter. It helps you build custom workout templates, log your sessions with details like rest timers and plate calculations, and analyze your progressive overload and workout consistency over time.

---

## Key Features

- **Offline-First Storage**: Powered by a robust, local SQLite database managed through [Drift](https://drift.simonbinder.eu/). Your workout data remains entirely on your device.
- **Rule-Engine Program Generator ("Make a Gym Program for Me")**: Automatically builds structured, localized training programs (e.g., Push/Pull/Legs, PHAT) based on your weekly frequency, fitness goals, and available equipment.
- **Active Workout Logger**:
  - Track sets, reps, weight, and set types (Warmup, Normal, Drop Set, Failure).
  - At-a-glance reference to historical performance ("Last Time") for progressive overload tracking.
  - Interactive rest timer banner with background alerts and system/audio notifications.
  - On-the-fly plate calculator and 1-Rep Max (1RM) estimation.
- **Interactive Analytics Dashboard**:
  - Weekly workout consistency charts using `fl_chart`.
  - Muscle group split distributions.
  - 1RM progression curve history for individual exercises.
- **Pre-seeded & Custom Exercises**: Loaded with 100+ standard movements from a seeded asset dataset, with full support for adding custom user exercises.
- **Data Export & Import**: Fully export your local database to JSON format or restore from an existing backup.

---

## Tech Stack & Architecture

- **Core**: Flutter SDK with Dart
- **State Management**: [Riverpod](https://riverpod.dev/) for robust, modular, and testable state handling.
- **Database**: [Drift](https://drift.simonbinder.eu/) (built on SQLite) for type-safe queries and live-updating reactive streams.
- **UI & Layout**: Custom design theme leveraging [Google Fonts](https://pub.dev/packages/google_fonts) (Outfit and Inter), smooth charts with [FL Chart](https://pub.dev/packages/fl_chart), and clean Material design iconography.
- **Notifications**: Rest timer alerts using [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications).

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.18+)
- Dart SDK (v3.0+)

### Setup & Run

1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd grit
   ```

2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate DB Classes (Drift)**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

5. **Run Tests**:
   ```bash
   flutter test
   ```

---

## Project Structure

```
lib/
├── assets/                     # Seed JSON datasets
├── database/                   # SQLite Drift schema configurations & migration/seed logic
├── models/                     # Shared models and type enums
├── providers/                  # Riverpod state managers (active workout, rest timer, etc.)
├── services/                   # Logic engines (notifications, program generator rule-engine)
└── ui/                         # Presentation layer
    ├── common/                 # Reusable custom UI components (e.g. Plate Calculator)
    ├── theme.dart              # Color themes, typography, and styling tokens
    └── *screen.dart            # Main application pages
```

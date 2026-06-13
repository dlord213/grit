# Build My Program - Feature Handoff Document

**Generated:** 2026-06-14T00:00:00Z  
**Status:** Production-ready  
**Version:** 1.0  

---

## 1. Feature Overview

"Build My Program" is an auto-generation wizard that creates workout template splits based on user preferences. Users answer a 3-step questionnaire (days/week, goal, equipment), and the system generates structured workout templates directly into the local SQLite database.

### User Flow
```
Dashboard "Build My Program" banner
  → ProgramQuestionnaireScreen (3-step wizard)
    → Step 1: Days per week (2, 3, 4, 5)
    → Step 2: Goal (Strength, Hypertrophy, Endurance, General Fitness)
    → Step 3: Equipment (Full Gym, Home Gym, Dumbbell Only, Bodyweight) [multi-select]
  → ProgramGenerator.generateProgram()
  → Templates written to DB
  → User returns to dashboard with new templates available
```

---

## 2. File Manifest

### Core Files

| File | Purpose |
|------|---------|
| `lib/ui/program_questionnaire_screen.dart` | 3-step wizard UI with animated option cards |
| `lib/services/program_generator.dart` | Business logic: maps user inputs to exercise selections, writes templates to DB |

### Dependencies

| File | Relationship |
|------|-------------|
| `lib/database/database.dart` | `createTemplate()` - writes WorkoutTemplate + TemplateExercises rows |
| `lib/ui/dashboard_screen.dart` | Entry point via `_buildProgramBanner()` - navigates to wizard |
| `lib/ui/theme.dart` | `GritTheme.primary`, `GritTheme.accent`, `GritTheme.accentViolet` used throughout UI |
| `assets/exercises_seed.json` | Seed data for exercises - all exercise names referenced by the generator must exist here |

---

## 3. Architecture

### ProgramQuestionnaireScreen (UI Layer)

**Type:** `ConsumerStatefulWidget` (Riverpod)

**State:**
```dart
int _currentStep = 0;          // 0, 1, 2
int _daysPerWeek = 3;          // default: 3
String _goal = 'Hypertrophy';  // default: Hypertrophy
Set<String> _selectedEquipment = {};  // multi-select, must be non-empty to finish
bool _isGenerating = false;
```

**Navigation:**
- Uses `PageController` with `NeverScrollableScrollPhysics` (manual step progression only)
- Back button goes to previous step or pops screen
- Next/Finish button calls `_generateProgram()` on final step
- Equipment step requires at least 1 selection to enable FINISH button

**UI Components:**
- `_AnimatedOptionCard` - Custom widget with scale animation on tap (elastic bounce)
- `_buildStepIndicator()` - 3-segment progress bar with sparkle icon on active step
- `_buildDaysStep()` - 2x2 grid of day count options (2, 3, 4, 5)
- `_buildGoalStep()` - ListView of 4 goal options with icons
- `_buildEquipmentStep()` - Multi-select ListView with checkbox indicators

### ProgramGenerator (Service Layer)

**Type:** Plain Dart class (not a provider)

**Constructor:** Takes `AppDatabase db` as dependency

**Entry Point:**
```dart
Future<int> generateProgram({
  required int daysPerWeek,
  required String goal,
  required Set<String> equipment,
}) async
```

**Returns:** Number of templates created

**Internal Flow:**
1. Calls `_getProgramStructure(days, goal, equipment)` to get hardcoded program structure
2. Fetches all exercises from DB via `db.getAllExercises()`
3. For each day in the structure:
   - Matches exercise names from the structure to DB exercises via fuzzy string matching
   - Creates template via `db.createTemplate(name, description, exerciseIds)`

**Exercise Matching Logic:**
```dart
// Priority 1: Exact match (case-insensitive)
e.name.toLowerCase() == name.toLowerCase()

// Priority 2: Contains match
e.name.toLowerCase().contains(name.toLowerCase())

// Priority 3: Reverse contains
name.toLowerCase().contains(e.name.toLowerCase())

// Fallback: First exercise in DB (should rarely happen)
allExercises.first
```

---

## 4. Program Structure Matrix

The generator uses hardcoded program structures organized by days/week and equipment type.

### Days × Equipment Matrix

| Days | Full Gym | Dumbbell Only | Bodyweight |
|------|----------|---------------|------------|
| 2 | Full Body A/B | DB Full Body A/B | BW Full Body A/B |
| 3 | PPL (Strength: Power A/B/C) | DB Push/Pull/Legs | BW Push/Pull/Legs |
| 4 | Upper/Lower A/B | DB Upper/Lower A/B | BW Upper/Lower A/B |
| 5 | PHAT (Power + Hypertrophy) | DB PPL + Upper/Lower | BW Push/Pull/Legs/Core/Conditioning |

### Program Splits by Goal

**3-Day Goal Variations:**
- **Strength:** Power A (Squat) / Power B (Bench) / Power C (Deadlift)
- **Hypertrophy/Endurance/General:** PPL or DB Push/Pull/Legs

**2/4/5-Day:** Goal does not affect structure (only equipment matters)

### Template Count by Configuration

| Config | Templates Generated |
|--------|-------------------|
| 2-day any | 2 |
| 3-day any | 3 |
| 4-day any | 4 |
| 5-day any | 5 |

---

## 5. Exercise Name Reference

All exercise names in the program structures must match exercises in `assets/exercises_seed.json`. Current exercise library (verified against seed data):

### Full Gym Exercises Referenced
- Barbell Back Squat, Barbell Bench Press, Barbell Row, Barbell Overhead Press
- Barbell Front Squat, Barbell Curl
- Deadlift, Romanian Deadlift (Barbell)
- Lat Pulldown, Cable Tricep Pushdown, Face Pull
- Dumbbell Shoulder Press, Dumbbell Lateral Raise, Dumbbell Curl
- Incline Dumbbell Bench Press, Hammer Curl
- Leg Press, Leg Extensions, Seated Leg Curl, Lying Leg Curl, Standing Calf Raise
- Skull Crushers, Ab Crunch, Plank

### Dumbbell-Only Exercises Referenced
- Dumbbell Bench Press, Dumbbell Row, Dumbbell Shoulder Press
- Dumbbell Lateral Raise, Dumbbell Rear Delt Fly, Dumbbell Curl
- Dumbbell Overhead Tricep Extension, Dumbbell Kickback
- Goblet Squat, Romanian Deadlift (Dumbbell), Dumbbell Lunges
- Step-ups, Hammer Curl, Russian Twist, Ab Crunch, Plank

### Bodyweight Exercises Referenced
- Push-up, Diamond Push-up, Pike Push-up, Dips
- Bodyweight Squat, Lunges, Bulgarian Split Squat
- Inverted Row, Chin-up, Superman, Reverse Snow Angel
- Glute Bridge, Single Leg Deadlift (Bodyweight), Pistol Squat Progression
- Plank, Russian Twist, Leg Raise, Ab Crunch
- Burpee, Mountain Climber, Jump Squat, Calf Raise

---

## 6. Database Interaction

### Templates Created By
```dart
// In program_generator.dart
await db.createTemplate(templateName, templateDesc, matchedExerciseIds);
```

### Database Method (database.dart:142)
```dart
Future<int> createTemplate(String name, String? description, List<int> exerciseIds) async {
  return transaction(() async {
    final templateId = await into(workoutTemplates).insert(
      WorkoutTemplatesCompanion.insert(
        name: name,
        description: Value(description),
      ),
    );
    for (int i = 0; i < exerciseIds.length; i++) {
      await into(templateExercises).insert(
        TemplateExercisesCompanion.insert(
          templateId: templateId,
          exerciseId: exerciseIds[i],
          sequenceOrder: i,
        ),
      );
    }
    return templateId;
  });
}
```

### Tables Written
- `WorkoutTemplates` - One row per generated template (name, description)
- `TemplateExercises` - One row per exercise in each template (templateId, exerciseId, sequenceOrder)

### Cascade Behavior
- Deleting a `WorkoutTemplate` cascades to delete its `TemplateExercises` rows

---

## 7. Integration Points

### Dashboard Entry (`dashboard_screen.dart`)

**Banner Widget:** `_buildProgramBanner()` - Purple accentViolet card with sparkle icon
**Navigation:** `Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramQuestionnaireScreen()))`

**Location in dashboard layout:**
1. Header (avatar + GRIT title + GP chip + add button)
2. Weekly Streak Tracker
3. **Build My Program Banner** ← here
4. Start Workout / No Templates Prompt
5. Workout Templates Grid
6. Recent Workouts

### Post-Generation Flow
1. SnackBar shows "Generated N workout templates successfully!"
2. `Navigator.pop(context)` returns to dashboard
3. `templatesStreamProvider` (reactive) auto-updates the templates grid
4. User can now tap any template to start a workout

---

## 8. UI Details

### Color Scheme
- **Selected state:** `GritTheme.primary` (hot pink) border + fill
- **Unselected state:** Surface color with divider border
- **Equipment accent:** `GritTheme.accent` (electric blue) for selection highlight
- **Wizard accent:** `GritTheme.accentViolet` (purple) for progress bar

### Animations
- `_AnimatedOptionCard`: Scale animation on tap (1.0 → 0.95 → 1.0 with elastic bounce)
- Page transitions: 350ms ease-in-out
- Option selection: 200ms animated container

### Responsive Behavior
- Days step: 2x2 grid with `childAspectRatio: 1.0`
- Goal/Equipment steps: ListView with separator widgets
- Scrollable on small screens via PageView + ListView

---

## 9. Known Limitations

1. **No custom split support** - Users cannot define their own exercise-per-day breakdown
2. **Goal only affects 3-day** - 2/4/5-day programs ignore the goal selection
3. **Equipment is multi-select but logic only handles single-category** - The code checks for `bodyweightOnly` and `dumbbellsOnly` (single-item sets), but multi-select combinations fall through to the default "full gym" path
4. **Exercise matching is fuzzy** - Could match wrong exercises if names are similar (e.g., "Dumbbell Row" vs "Barbell Row")
5. **No undo** - Generated templates cannot be bulk-removed; user must delete individually
6. **No progress save** - If user navigates away mid-wizard, all selections are lost
7. **Hardcoded exercises** - Adding new exercises to the seed data doesn't automatically add them to programs

---

## 10. Testing Checklist

- [ ] 2-day Full Gym generates 2 templates with correct exercises
- [ ] 3-day Strength generates Power A/B/C split
- [ ] 3-day Hypertrophy generates PPL split
- [ ] 4-day generates Upper/Lower A/B
- [ ] 5-day Full Gym generates PHAT-style split
- [ ] Dumbbell-only configurations use only DB exercises
- [ ] Bodyweight-only configurations use only BW exercises
- [ ] FINISH button disabled when no equipment selected
- [ ] Templates appear in dashboard grid after generation
- [ ] Templates can be started as workouts
- [ ] Templates can be deleted individually
- [ ] Back button navigates through wizard steps
- [ ] Loading spinner shows during generation
- [ ] Error snackbar shows on failure
- [ ] Snackbar shows success count

---

## 11. Future Enhancement Ideas

1. **Custom split builder** - Let users define A/B/C/D day structures
2. **Progressive overload suggestions** - Auto-increase weights based on history
3. **Goal-aware programming for all days** - Adjust rep ranges and exercise selection per goal
4. **Equipment combination handling** - Support "Home Gym + Dumbbells" properly
5. **Template regeneration** - "Regenerate" button that replaces existing templates
6. **Program templates marketplace** - Pre-built programs by fitness professionals
7. **Periodization support** - Auto-cycle between strength/hypertrophy blocks
8. **Rest day suggestions** - Recommend rest day placement based on training split

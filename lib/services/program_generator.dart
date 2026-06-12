import '../database/database.dart';

class ProgramGenerator {
  final AppDatabase db;

  ProgramGenerator(this.db);

  /// Generates a program template based on questionnaire input.
  /// Returns the number of templates created.
  Future<int> generateProgram({
    required int daysPerWeek,
    required String goal, // 'Hypertrophy', 'Strength', 'General Fitness'
    required String equipment, // 'Full Gym', 'Home Gym', 'Dumbbells Only'
  }) async {
    // 1. Determine program layout
    final List<Map<String, dynamic>> programStructure = _getProgramStructure(daysPerWeek, goal, equipment);

    // 2. Query all available exercises from DB to match by name
    final allExercises = await db.getAllExercises();

    int templatesCreated = 0;

    for (final dayConfig in programStructure) {
      final String templateName = dayConfig['name'] as String;
      final String templateDesc = dayConfig['description'] as String;
      final List<String> targetExerciseNames = List<String>.from(dayConfig['exercises'] as List);

      // Map target exercise names to actual Exercise records
      final List<int> matchedExerciseIds = [];
      for (final name in targetExerciseNames) {
        // Find exact match or partial match or fallback
        final match = allExercises.firstWhere(
          (e) => e.name.toLowerCase() == name.toLowerCase() ||
                 e.name.toLowerCase().contains(name.toLowerCase()),
          orElse: () {
            // Find any fallback exercise matching the name as substring
            return allExercises.firstWhere(
              (e) => name.toLowerCase().contains(e.name.toLowerCase()),
              orElse: () => allExercises.first, // Fallback to first exercise if completely not found
            );
          },
        );
        matchedExerciseIds.add(match.id);
      }

      if (matchedExerciseIds.isNotEmpty) {
        await db.createTemplate(templateName, templateDesc, matchedExerciseIds);
        templatesCreated++;
      }
    }

    return templatesCreated;
  }

  List<Map<String, dynamic>> _getProgramStructure(int days, String goal, String equipment) {
    final bool dumbbellsOnly = equipment == 'Dumbbells Only';

    if (days == 2) {
      // 2-Day Split: Full Body A / Full Body B
      if (dumbbellsOnly) {
        return [
          {
            'name': '2-Day Dumbbell Full Body A',
            'description': 'Full body strength session focusing on dumbbell exercises.',
            'exercises': [
              'Goblet Squat',
              'Dumbbell Bench Press',
              'Dumbbell Row',
              'Dumbbell Shoulder Press',
              'Dumbbell Curl',
              'Ab Crunch',
            ],
          },
          {
            'name': '2-Day Dumbbell Full Body B',
            'description': 'Full body accessory session targeting lower body hinge and upper pulls.',
            'exercises': [
              'Romanian Deadlift (Dumbbell)',
              'Dumbbell Lunges',
              'Dumbbell Lateral Raise',
              'Dumbbell Overhead Tricep Extension',
              'Hammer Curl',
              'Plank',
            ],
          }
        ];
      } else {
        return [
          {
            'name': '2-Day Full Body A',
            'description': 'Heavy compound lifting session for maximum full body recruitment.',
            'exercises': [
              'Barbell Back Squat',
              'Barbell Bench Press',
              'Barbell Row',
              'Dumbbell Lateral Raise',
              'Barbell Curl',
              'Ab Crunch',
            ],
          },
          {
            'name': '2-Day Full Body B',
            'description': 'Deadlift and pressing focused full body workout.',
            'exercises': [
              'Deadlift',
              'Barbell Overhead Press',
              'Lat Pulldown',
              'Leg Extensions',
              'Cable Tricep Pushdown',
              'Plank',
            ],
          }
        ];
      }
    } else if (days == 3) {
      // 3-Day Split: Push / Pull / Legs or Full Body
      if (goal == 'Strength') {
        // 3-Day Power/Strength Full Body (Squat, Bench, Deadlift focus)
        return [
          {
            'name': '3-Day Power A (Squat Focus)',
            'description': 'High strength squat focus day.',
            'exercises': [
              'Barbell Back Squat',
              'Barbell Bench Press',
              'Barbell Row',
              'Dumbbell Lateral Raise',
              'Ab Crunch',
            ],
          },
          {
            'name': '3-Day Power B (Bench Focus)',
            'description': 'Bench press strength focus day with heavy pulls.',
            'exercises': [
              'Barbell Bench Press',
              'Barbell Overhead Press',
              'Lat Pulldown',
              'Dumbbell Curl',
              'Plank',
            ],
          },
          {
            'name': '3-Day Power C (Deadlift Focus)',
            'description': 'Heavy deadlift pulling focus day.',
            'exercises': [
              'Deadlift',
              'Barbell Front Squat',
              'Dumbbell Row',
              'Skull Crushers',
              'Lying Leg Curl',
            ],
          }
        ];
      } else {
        // Push / Pull / Legs
        if (dumbbellsOnly) {
          return [
            {
              'name': '3-Day Dumbbell Push',
              'description': 'Dumbbell-only push day targeting chest, shoulders, and triceps.',
              'exercises': [
                'Dumbbell Bench Press',
                'Dumbbell Shoulder Press',
                'Dumbbell Lateral Raise',
                'Dumbbell Overhead Tricep Extension',
                'Ab Crunch',
              ],
            },
            {
              'name': '3-Day Dumbbell Pull',
              'description': 'Dumbbell-only pull day targeting back, biceps, and rear shoulders.',
              'exercises': [
                'Dumbbell Row',
                'Dumbbell Rear Delt Fly',
                'Dumbbell Curl',
                'Hammer Curl',
                'Plank',
              ],
            },
            {
              'name': '3-Day Dumbbell Legs',
              'description': 'Dumbbell-only lower body day focusing on quads, hamstrings, and calves.',
              'exercises': [
                'Goblet Squat',
                'Romanian Deadlift (Dumbbell)',
                'Dumbbell Lunges',
                'Step-ups',
                'Russian Twist',
              ],
            }
          ];
        } else {
          return [
            {
              'name': '3-Day PPL - Push',
              'description': 'Push day targeting Chest, Shoulders, and Triceps.',
              'exercises': [
                'Barbell Bench Press',
                'Dumbbell Shoulder Press',
                'Dumbbell Lateral Raise',
                'Cable Tricep Pushdown',
                'Incline Dumbbell Bench Press',
              ],
            },
            {
              'name': '3-Day PPL - Pull',
              'description': 'Pull day targeting Back and Biceps.',
              'exercises': [
                'Lat Pulldown',
                'Barbell Row',
                'Dumbbell Curl',
                'Face Pull',
                'Hammer Curl',
              ],
            },
            {
              'name': '3-Day PPL - Legs',
              'description': 'Lower body day targeting Quads, Hamstrings, and Calves.',
              'exercises': [
                'Barbell Back Squat',
                'Romanian Deadlift (Barbell)',
                'Leg Press',
                'Seated Leg Curl',
                'Standing Calf Raise',
              ],
            }
          ];
        }
      }
    } else if (days == 4) {
      // 4-Day Split: Upper / Lower A & B
      if (dumbbellsOnly) {
        return [
          {
            'name': '4-Day Dumbbell Upper A',
            'description': 'Dumbbell chest and row focus upper body.',
            'exercises': [
              'Dumbbell Bench Press',
              'Dumbbell Row',
              'Dumbbell Shoulder Press',
              'Dumbbell Curl',
              'Dumbbell Overhead Tricep Extension',
            ],
          },
          {
            'name': '4-Day Dumbbell Lower A',
            'description': 'Dumbbell squat focus lower body.',
            'exercises': [
              'Goblet Squat',
              'Romanian Deadlift (Dumbbell)',
              'Dumbbell Lunges',
              'Russian Twist',
            ],
          },
          {
            'name': '4-Day Dumbbell Upper B',
            'description': 'Dumbbell shoulder press and pull-up focus upper body.',
            'exercises': [
              'Dumbbell Shoulder Press',
              'Dumbbell Row',
              'Dumbbell Bench Press',
              'Hammer Curl',
              'Dumbbell Kickback',
            ],
          },
          {
            'name': '4-Day Dumbbell Lower B',
            'description': 'Dumbbell hinge focus lower body.',
            'exercises': [
              'Romanian Deadlift (Dumbbell)',
              'Goblet Squat',
              'Step-ups',
              'Plank',
            ],
          }
        ];
      } else {
        return [
          {
            'name': '4-Day Upper A',
            'description': 'Power focus upper body day.',
            'exercises': [
              'Barbell Bench Press',
              'Barbell Row',
              'Dumbbell Shoulder Press',
              'Lat Pulldown',
              'Barbell Curl',
              'Skull Crushers',
            ],
          },
          {
            'name': '4-Day Lower A',
            'description': 'Squat focus lower body day.',
            'exercises': [
              'Barbell Back Squat',
              'Romanian Deadlift (Barbell)',
              'Leg Extensions',
              'Seated Leg Curl',
              'Standing Calf Raise',
            ],
          },
          {
            'name': '4-Day Upper B',
            'description': 'Hypertrophy focus upper body day.',
            'exercises': [
              'Dumbbell Bench Press',
              'Dumbbell Row',
              'Dumbbell Lateral Raise',
              'Dumbbell Curl',
              'Cable Tricep Pushdown',
              'Face Pull',
            ],
          },
          {
            'name': '4-Day Lower B',
            'description': 'Hinge focus lower body day.',
            'exercises': [
              'Deadlift',
              'Leg Press',
              'Lying Leg Curl',
              'Standing Calf Raise',
              'Plank',
            ],
          }
        ];
      }
    } else {
      // 5-Day Split: Push / Pull / Legs / Upper / Lower
      if (dumbbellsOnly) {
        return [
          {
            'name': '5-Day Dumbbell Push',
            'description': 'Push day targeting Chest and Triceps.',
            'exercises': ['Dumbbell Bench Press', 'Dumbbell Shoulder Press', 'Dumbbell Lateral Raise', 'Dumbbell Kickback'],
          },
          {
            'name': '5-Day Dumbbell Pull',
            'description': 'Pull day targeting Back and Biceps.',
            'exercises': ['Dumbbell Row', 'Dumbbell Rear Delt Fly', 'Dumbbell Curl', 'Hammer Curl'],
          },
          {
            'name': '5-Day Dumbbell Legs',
            'description': 'Lower body focus.',
            'exercises': ['Goblet Squat', 'Romanian Deadlift (Dumbbell)', 'Dumbbell Lunges', 'Plank'],
          },
          {
            'name': '5-Day Dumbbell Upper',
            'description': 'Upper body accessory pump.',
            'exercises': ['Dumbbell Bench Press', 'Dumbbell Row', 'Dumbbell Shoulder Press', 'Dumbbell Curl'],
          },
          {
            'name': '5-Day Dumbbell Lower',
            'description': 'Lower body accessory pump.',
            'exercises': ['Romanian Deadlift (Dumbbell)', 'Goblet Squat', 'Step-ups', 'Russian Twist'],
          }
        ];
      } else {
        return [
          {
            'name': '5-Day PHAT - Upper Power',
            'description': 'Heavy upper body compound power.',
            'exercises': ['Barbell Bench Press', 'Barbell Row', 'Barbell Overhead Press', 'Lat Pulldown', 'Barbell Curl'],
          },
          {
            'name': '5-Day PHAT - Lower Power',
            'description': 'Heavy lower body compound power.',
            'exercises': ['Barbell Back Squat', 'Romanian Deadlift (Barbell)', 'Leg Press', 'Standing Calf Raise'],
          },
          {
            'name': '5-Day PHAT - Push Hypertrophy',
            'description': 'Hypertrophy session for pushing muscles.',
            'exercises': ['Dumbbell Bench Press', 'Dumbbell Shoulder Press', 'Dumbbell Lateral Raise', 'Cable Tricep Pushdown'],
          },
          {
            'name': '5-Day PHAT - Pull Hypertrophy',
            'description': 'Hypertrophy session for pulling muscles.',
            'exercises': ['Lat Pulldown', 'Dumbbell Row', 'Dumbbell Curl', 'Face Pull', 'Hammer Curl'],
          },
          {
            'name': '5-Day PHAT - Legs Hypertrophy',
            'description': 'Hypertrophy session for legs.',
            'exercises': ['Leg Press', 'Lying Leg Curl', 'Leg Extensions', 'Seated Leg Curl', 'Standing Calf Raise'],
          }
        ];
      }
    }
  }
}

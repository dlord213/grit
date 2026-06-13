enum TargetMuscle {
  Chest,
  Back,
  Quads,
  Hamstrings,
  Shoulders,
  Biceps,
  Triceps,
  Abs,
  Calves,
  FullBody;

  static TargetMuscle fromName(String name) {
    return TargetMuscle.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() ||
             e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      orElse: () => TargetMuscle.FullBody,
    );
  }
}

enum Equipment {
  Barbell,
  Dumbbell,
  Machine,
  Cables,
  Bodyweight,
  SmithMachine;

  static Equipment fromName(String name) {
    return Equipment.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() ||
             e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      orElse: () => Equipment.Bodyweight,
    );
  }
}

enum ExperienceLevel {
  Beginner,
  Moderate,
  Intermediate;

  static ExperienceLevel fromName(String name) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() ||
             e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      orElse: () => ExperienceLevel.Beginner,
    );
  }
}

enum MuscleFocus {
  Chest,
  Back,
  Legs,
  Arms,
  Shoulders;

  List<TargetMuscle> get targetMuscles {
    switch (this) {
      case MuscleFocus.Chest:
        return [TargetMuscle.Chest];
      case MuscleFocus.Back:
        return [TargetMuscle.Back];
      case MuscleFocus.Legs:
        return [TargetMuscle.Quads, TargetMuscle.Hamstrings, TargetMuscle.Calves];
      case MuscleFocus.Arms:
        return [TargetMuscle.Biceps, TargetMuscle.Triceps];
      case MuscleFocus.Shoulders:
        return [TargetMuscle.Shoulders];
    }
  }

  static MuscleFocus fromName(String name) {
    return MuscleFocus.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() ||
             e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      orElse: () => MuscleFocus.Chest,
    );
  }
}

enum SetType {
  Normal,
  Warmup,
  DropSet,
  Failure;

  static SetType fromName(String name) {
    return SetType.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() ||
             e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      orElse: () => SetType.Normal,
    );
  }
}

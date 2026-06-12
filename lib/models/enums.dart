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

class BiometricConfig {
  final String fullName;
  final int age;
  final double currentWeight;
  final double targetWeight;
  final double height;

  const BiometricConfig({
    this.fullName = '',
    this.age = 0,
    this.currentWeight = 154,
    this.targetWeight = 180,
    this.height = 70,
  });

  BiometricConfig copyWith({
    String? fullName,
    int? age,
    double? currentWeight,
    double? targetWeight,
    double? height,
  }) {
    return BiometricConfig(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
    );
  }

  double get bmi {
    if (height <= 0 || currentWeight <= 0) return 0;
    final heightMeters = height * 0.0254;
    final weightKg = currentWeight * 0.453592;
    return weightKg / (heightMeters * heightMeters);
  }

  String get bmiFormatted => bmi > 0 ? bmi.toStringAsFixed(1) : '--';

  String get bmiCategory {
    if (bmi <= 0) return '';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String get heightFormatted {
    final totalInches = height.round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet'$inches\"";
  }

  String get currentWeightFormatted => '${currentWeight.round()} lbs';
  String get targetWeightFormatted => '${targetWeight.round()} lbs';

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'age': age,
    'currentWeight': currentWeight,
    'targetWeight': targetWeight,
    'height': height,
  };

  factory BiometricConfig.fromJson(Map<String, dynamic> json) => BiometricConfig(
    fullName: json['fullName'] as String? ?? '',
    age: (json['age'] as num?)?.toInt() ?? 0,
    currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 154,
    targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 180,
    height: (json['height'] as num?)?.toDouble() ?? 70,
  );
}

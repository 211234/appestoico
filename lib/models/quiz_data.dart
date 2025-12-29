class QuizData {
  String? ageRange;
  String? gender;
  String? country;
  String? religiousBelief;
  String? spiritualPracticeLevel;
  String? spiritualPracticeFrequency;
  List<String> dailyChallenges;
  List<String> stoicPaths;
  String? stoicLevel;

  QuizData({
    this.ageRange,
    this.gender,
    this.country,
    this.religiousBelief,
    this.spiritualPracticeLevel,
    this.spiritualPracticeFrequency,
    this.dailyChallenges = const [],
    this.stoicPaths = const [],
    this.stoicLevel,
  });

  // Convertir a JSON para enviar al API
  Map<String, dynamic> toJson() {
    return {
      'age_range': ageRange,
      'gender': gender,
      'country': country,
      'religious_belief': religiousBelief,
      'spiritual_practice_level': spiritualPracticeLevel,
      'spiritual_practice_frequency': spiritualPracticeFrequency,
      'daily_challenges': dailyChallenges,
      'stoic_paths': stoicPaths,
      'stoic_level': stoicLevel,
    };
  }

  // Crear desde JSON (respuesta del API)
  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      ageRange: json['age_range'],
      gender: json['gender'],
      country: json['country'],
      religiousBelief: json['religious_belief'],
      spiritualPracticeLevel: json['spiritual_practice_level'],
      spiritualPracticeFrequency: json['spiritual_practice_frequency'],
      dailyChallenges: List<String>.from(json['daily_challenges'] ?? []),
      stoicPaths: List<String>.from(json['stoic_paths'] ?? []),
      stoicLevel: json['stoic_level'],
    );
  }

  // Verificar si el Quiz1 está completo (datos personales)
  bool isQuiz1Complete() {
    return ageRange != null && gender != null && country != null;
  }

  // Verificar si el Quiz2 está completo (espiritualidad)
  bool isQuiz2Complete() {
    return religiousBelief != null &&
        spiritualPracticeLevel != null &&
        spiritualPracticeFrequency != null;
  }

  // Verificar si el Quiz3 está completo (recordatorios diarios)
  bool isQuiz3Complete() {
    return dailyChallenges.isNotEmpty;
  }

  // Verificar si el Quiz4 está completo (camino estoico)
  bool isQuiz4Complete() {
    return stoicPaths.isNotEmpty;
  }

  // Verificar si el Quiz5 está completo (nivel de conocimiento)
  bool isQuiz5Complete() {
    return stoicLevel != null;
  }

  // Verificar si todo el quiz está completo
  bool isComplete() {
    return isQuiz1Complete() &&
        isQuiz2Complete() &&
        isQuiz3Complete() &&
        isQuiz4Complete() &&
        isQuiz5Complete();
  }
}

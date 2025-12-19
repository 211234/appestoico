import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_data.dart';

class QuizService {
  static QuizData _currentQuiz = QuizData();

  // Obtener el quiz actual
  static QuizData get currentQuiz => _currentQuiz;

  // Actualizar datos del Quiz1 (Datos Personales)
  static void updateQuiz1({
    required String ageRange,
    required String gender,
    required String country,
  }) {
    _currentQuiz.ageRange = ageRange;
    _currentQuiz.gender = gender;
    _currentQuiz.country = country;
    _saveToPreferences();
  }

  // Actualizar datos del Quiz2 (Espiritualidad)
  static void updateQuiz2({
    required String religiousBelief,
    required String spiritualPracticeLevel,
    required String spiritualPracticeFrequency,
  }) {
    _currentQuiz.religiousBelief = religiousBelief;
    _currentQuiz.spiritualPracticeLevel = spiritualPracticeLevel;
    _currentQuiz.spiritualPracticeFrequency = spiritualPracticeFrequency;
    _saveToPreferences();
  }

  // Actualizar datos del Quiz3 (Desafíos Diarios)
  static void updateQuiz3({required List<String> dailyChallenges}) {
    _currentQuiz.dailyChallenges = dailyChallenges;
    _saveToPreferences();
  }

  // Actualizar datos del Quiz4 (Camino Estoico)
  static void updateQuiz4({required List<String> stoicPaths}) {
    _currentQuiz.stoicPaths = stoicPaths;
    _saveToPreferences();
  }

  // Actualizar datos del Quiz5 (Nivel de Conocimiento)
  static void updateQuiz5({required String knowledgeLevel}) {
    _currentQuiz.knowledgeLevel = knowledgeLevel;
    _saveToPreferences();
  }

  // Limpiar quiz
  static void clearQuiz() {
    _currentQuiz = QuizData();
    _clearPreferences();
  }

  // Guardar en SharedPreferences
  static Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentQuiz.ageRange != null) {
      await prefs.setString('quiz_age_range', _currentQuiz.ageRange!);
    }
    if (_currentQuiz.gender != null) {
      await prefs.setString('quiz_gender', _currentQuiz.gender!);
    }
    if (_currentQuiz.country != null) {
      await prefs.setString('quiz_country', _currentQuiz.country!);
    }
    if (_currentQuiz.religiousBelief != null) {
      await prefs.setString(
        'quiz_religious_belief',
        _currentQuiz.religiousBelief!,
      );
    }
    if (_currentQuiz.spiritualPracticeLevel != null) {
      await prefs.setString(
        'quiz_spiritual_practice_level',
        _currentQuiz.spiritualPracticeLevel!,
      );
    }
    if (_currentQuiz.spiritualPracticeFrequency != null) {
      await prefs.setString(
        'quiz_spiritual_practice_frequency',
        _currentQuiz.spiritualPracticeFrequency!,
      );
    }
    await prefs.setStringList(
      'quiz_daily_challenges',
      _currentQuiz.dailyChallenges,
    );
    await prefs.setStringList('quiz_stoic_paths', _currentQuiz.stoicPaths);
    if (_currentQuiz.knowledgeLevel != null) {
      await prefs.setString(
        'quiz_knowledge_level',
        _currentQuiz.knowledgeLevel!,
      );
    }
  }

  // Cargar desde SharedPreferences
  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currentQuiz = QuizData(
      ageRange: prefs.getString('quiz_age_range'),
      gender: prefs.getString('quiz_gender'),
      country: prefs.getString('quiz_country'),
      religiousBelief: prefs.getString('quiz_religious_belief'),
      spiritualPracticeLevel: prefs.getString('quiz_spiritual_practice_level'),
      spiritualPracticeFrequency: prefs.getString(
        'quiz_spiritual_practice_frequency',
      ),
      dailyChallenges: prefs.getStringList('quiz_daily_challenges') ?? [],
      stoicPaths: prefs.getStringList('quiz_stoic_paths') ?? [],
      knowledgeLevel: prefs.getString('quiz_knowledge_level'),
    );
  }

  // Limpiar SharedPreferences
  static Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_age_range');
    await prefs.remove('quiz_gender');
    await prefs.remove('quiz_country');
    await prefs.remove('quiz_religious_belief');
    await prefs.remove('quiz_spiritual_practice_level');
    await prefs.remove('quiz_spiritual_practice_frequency');
    await prefs.remove('quiz_daily_challenges');
    await prefs.remove('quiz_stoic_paths');
    await prefs.remove('quiz_knowledge_level');
  }
}

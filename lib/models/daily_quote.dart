class DailyQuote {
  final int id;
  final String quote;
  final String author;
  final String category;
  final String date;
  final int? dayOfYear;
  final bool? isActive;
  final bool isPersonalized;
  final String? explanation;
  final String? originalAuthor;
  final String? originalCategory;

  DailyQuote({
    required this.id,
    required this.quote,
    required this.author,
    required this.category,
    required this.date,
    this.dayOfYear,
    this.isActive,
    this.isPersonalized = false,
    this.explanation,
    this.originalAuthor,
    this.originalCategory,
  });

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    // Priorizar frase personalizada si existe
    final bool isPersonalized = json['is_personalized'] == true;
    final String quote = isPersonalized
        ? (json['personalized_quote'] ?? json['quote'])
        : json['quote'];

    return DailyQuote(
      id: json['id'],
      quote: quote,
      author: json['original_author'] ?? json['author'],
      category: json['original_category'] ?? json['category'],
      date: json['date'],
      dayOfYear: json['day_of_year'],
      isActive: json['is_active'],
      isPersonalized: isPersonalized,
      explanation: json['explanation'],
      originalAuthor: json['original_author'],
      originalCategory: json['original_category'],
    );
  }
}

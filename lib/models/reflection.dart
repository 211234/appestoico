class Reflection {
  final String? id;
  final String? date;
  final String? time;
  final String? text;
  final String?
  morningText; // Mantener para compatibilidad con código existente
  final String?
  eveningText; // Mantener para compatibilidad con código existente
  final String? createdAt;
  final String? updatedAt;

  Reflection({
    this.id,
    this.date,
    this.time,
    this.text,
    this.morningText,
    this.eveningText,
    this.createdAt,
    this.updatedAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    // Priorizar el campo 'text' del nuevo formato
    final reflectionText = json['text']?.toString();

    return Reflection(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      date:
          json['date']?.toString() ??
          json['created_at']?.toString().split('T')[0],
      time: json['time']?.toString(),
      text: reflectionText,
      // Para compatibilidad, si existe 'text', usarlo también como morningText
      morningText: reflectionText ?? json['morning_text']?.toString(),
      eveningText: json['evening_text']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (text != null) data['text'] = text;
    if (date != null) data['date'] = date;
    return data;
  }

  bool get hasReflection => text != null && text!.isNotEmpty;
  bool get hasMorningReflection =>
      morningText != null && morningText!.isNotEmpty;
  bool get hasEveningReflection =>
      eveningText != null && eveningText!.isNotEmpty;
}

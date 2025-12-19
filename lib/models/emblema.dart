class Emblema {
  final String id;
  final String name;
  final String description;
  final String type;
  final String faceUrlm;
  final String imageUrlm;

  Emblema({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.faceUrlm,
    required this.imageUrlm,
  });

  factory Emblema.fromJson(Map<String, dynamic> json) {
    return Emblema(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      faceUrlm: json['face_urlm'] ?? '',
      imageUrlm: json['image_urlm'] ?? '',
    );
  }
}

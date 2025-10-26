class Event {
  final String id;
  final String title;

  // Description & media boleh null (opsional)
  final String? description;

  final DateTime dateTime;
  final String category;
  final String? imagePath;
  final String? locationUrl;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.category,
    this.imagePath,
    this.locationUrl,
  });

  // Konversi object Event menjadi Map untuk disimpan di JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(), // Format ISO untuk JSON
      'category': category,
      'imagePath': imagePath,
      'locationUrl': locationUrl,
    };
  }

  // Mengubah Map JSON menjadi object Event
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      category: map['category'],
      imagePath: map['imagePath'],
      locationUrl: map['locationUrl'],
    );
  }
}

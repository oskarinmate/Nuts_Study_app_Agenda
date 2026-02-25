class Event {
  final String id;
  final String title;
  final DateTime date;

  Event({required this.id, required this.title, required this.date});

  // Convertir para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(), // Guardamos la fecha como texto
    };
  }

  // Convertir de SQLite a objeto
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
    );
  }
}
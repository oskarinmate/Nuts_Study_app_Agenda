class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int? folderId; // 🔥 Nuevo campo para la relación

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.folderId, // Opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'folderId': folderId, // 🔥 Se guarda en la DB
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      folderId: map['folderId'], // 🔥 Se recupera de la DB
    );
  }
}
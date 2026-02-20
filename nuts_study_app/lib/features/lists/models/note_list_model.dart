class NoteList {
  final int? id;
  final String title;
  final DateTime createdAt;

  NoteList({
    this.id,
    required this.title,
    required this.createdAt,
  });

  NoteList copyWith({
    int? id,
    String? title,
  }) {
    return NoteList(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt,
    );
  }

  factory NoteList.fromMap(Map<String, dynamic> map) {
    return NoteList(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

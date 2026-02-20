class NoteListItem {
  final int? id;
  final int listId;
  final String text;
  final bool isDone;

  NoteListItem({
    this.id,
    required this.listId,
    required this.text,
    required this.isDone,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'listId': listId,
        'text': text,
        'isDone': isDone ? 1 : 0,
      };

  factory NoteListItem.fromMap(Map<String, dynamic> map) {
    return NoteListItem(
      id: map['id'],
      listId: map['listId'],
      text: map['text'],
      isDone: map['isDone'] == 1,
    );
  }

  NoteListItem copyWith({
    int? id,
    int? listId,
    String? text,
    bool? isDone,
  }) {
    return NoteListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}

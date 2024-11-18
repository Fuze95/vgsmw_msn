enum NoteStatus {
  active,
  archived
}

class Note {
  final int? id;
  String title;
  String content;
  DateTime createdAt;
  DateTime modifiedAt;
  String? label;
  String? imagePath;
  NoteStatus status;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.label,
    this.imagePath,
    this.status = NoteStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'label': label,
      'image_path': imagePath,
      'status': status.index,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      modifiedAt: DateTime.parse(map['modified_at']),
      label: map['label'],
      imagePath: map['image_path'],
      status: NoteStatus.values[map['status'] ?? 0],
    );
  }
}
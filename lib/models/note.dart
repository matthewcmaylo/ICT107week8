// Note is the plain Dart model that mirrors one row of the "notes" SQLite
// table. Keeping it separate from the database code lets the UI work with
// a typed object instead of raw Map<String, dynamic> results.
class Note {
  final int? id; // null until the row has been inserted by SQLite
  final String title;
  final String description;
  final bool done;

  const Note({
    this.id,
    required this.title,
    required this.description,
    this.done = false,
  });

  // Converts this Note into a Map so sqflite can write it as a row.
  // SQLite has no boolean type, so `done` is stored as 0/1.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'done': done ? 1 : 0,
    };
  }

  // Builds a Note from a sqflite row (used for CRUD reads).
  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      done: (map['done'] as int) == 1,
    );
  }

  // Builds a Note from decoded JSON (used by the "Import from JSON" feature).
  // JSON encodes booleans natively, so no 0/1 conversion is needed here.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String,
      description: json['description'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  Note copyWith({int? id, String? title, String? description, bool? done}) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
    );
  }
}

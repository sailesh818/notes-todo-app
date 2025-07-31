class Note {
  final int? id;
  final String title;
  final String content;
  final String timestamp;

  Note({this.id, required this.title, required this.content, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      timestamp: map['timestamp'],
    );
  }
}

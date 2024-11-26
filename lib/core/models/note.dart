import 'device/index.dart';

class Note {
  final String id;
  final String content;
  final DateTime creationDate;
  Device? device;

  Note({
    required this.id,
    required this.content,
    required this.creationDate,
    this.device,
  });

  Note copy({
    String? id,
    String? content,
    DateTime? creationDate,
    Device? device,
  }) =>
      Note(
        id: id ?? this.id,
        content: content ?? this.content,
        creationDate: creationDate ?? this.creationDate,
        device: device ?? this.device,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'creationDate': creationDate.toIso8601String(),
    'device': device?.toJson(),
  };
}

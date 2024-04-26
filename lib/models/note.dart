import 'package:que_app/models/device.dart';

class Note {
  final String id;
  final String content;
  final DateTime creationDate;
  Device? device;

  Note({required this.id, required this.content, required this.creationDate, this.device});
}
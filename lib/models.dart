import 'package:hive/hive.dart';
part 'models.g.dart';

@HiveType(typeId: 0)
class Note {

  Note({required this.title, required this.content});

  @HiveField(0)
  String title;

  @HiveField(1)
  String content;
}

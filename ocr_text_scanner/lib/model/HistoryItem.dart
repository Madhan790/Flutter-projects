import 'package:hive/hive.dart';

part 'HistoryItem.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  late String imagePath;

  @HiveField(1)
  late String firstLine;

  @HiveField(2)
  late String time; // Make sure time is stored as a string

  @HiveField(3)
  late String textFilePath;

  // Define title and subtitle properties
  String get title => firstLine; // Assuming firstLine as title
  String get subtitle => time; // Assuming time as subtitle

  HistoryItem({
    required this.imagePath,
    required this.firstLine,
    required this.time,
    required this.textFilePath,
  });

  // Deserialize the object from a map
  static HistoryItem fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      imagePath: map['imagePath'],
      firstLine: map['firstLine'],
      time: map['time'],
      textFilePath: map['textFilePath'],
    );
  }

  // Serialize the object to a map
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'firstLine': firstLine,
      'time': time,
      'textFilePath': textFilePath,
    };
  }
}

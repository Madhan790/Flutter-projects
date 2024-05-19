import 'package:hive/hive.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 32; // Unique identifier for this type of object

  @override
  HistoryItem read(BinaryReader reader) {
    final map = reader.readMap(); // Read the map
    return HistoryItem.fromMap(Map<String, dynamic>.from(map)); // Deserialize the object
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer.writeMap(obj.toMap()); // Serialize the object
  }
}

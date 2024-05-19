import 'package:ocr_text_scanner/model/HistoryItem.dart';

class History {
  static List<HistoryItem> _history = [];

  static List<HistoryItem> get history => _history;

  static void addItem(HistoryItem item) {
    _history.insert(0, item);
  }
}

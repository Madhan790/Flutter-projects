import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';

class HistoryProvider extends ChangeNotifier {
  Box<HistoryItem>? _historyBox;

  HistoryProvider() {
    _init();
  }

  Future<void> _init() async {
    print("Initializing Hive");
    await Hive.initFlutter();
    print("Opening history box");
    _historyBox = await Hive.openBox<HistoryItem>('history');
    print("History box opened");
    notifyListeners();
  }

  void addToHistory(HistoryItem item) {
    _historyBox?.add(item);
    notifyListeners();
  }

  List<HistoryItem> get history {
    if (_historyBox != null && _historyBox!.isOpen) {
      return _historyBox!.values.toList().cast<HistoryItem>();
    } else {
      return [];
    }
  }

  void removeFromHistory(int index) {
    _historyBox?.deleteAt(index);
    notifyListeners();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';
import 'package:ocr_text_scanner/pages/EditTextPage.dart';
import 'package:hive/hive.dart';

class DetailViewPage extends StatefulWidget {
  final HistoryItem historyItem;

  const DetailViewPage({Key? key, required this.historyItem}) : super(key: key);

  @override
  _DetailViewPageState createState() => _DetailViewPageState();
}

class _DetailViewPageState extends State<DetailViewPage> {
  late HistoryItem _editedHistoryItem;

  @override
  void initState() {
    super.initState();
    _editedHistoryItem = widget.historyItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail View"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToEditTextPage(context),
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () => _copyTextToClipboard(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _editedHistoryItem.firstLine,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 20),
              Image.file(
                File(_editedHistoryItem.imagePath),
                width: 200,
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditTextPage(BuildContext context) async {
    final editedText = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTextPage(initialText: _editedHistoryItem.firstLine)),
    );
    if (editedText != null) {
      setState(() {
        _editedHistoryItem.firstLine = editedText;
      });
      await _updateHistoryItem(_editedHistoryItem);
    }
  }

  void _copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: _editedHistoryItem.firstLine));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Text copied to clipboard"),
      ),
    );
  }

  Future<void> _updateHistoryItem(HistoryItem item) async {
    final box = await Hive.openBox<HistoryItem>('history');
    await box.put(item.key, item);
  }
}

import 'package:flutter/material.dart';

class EditTextPage extends StatefulWidget {
  final String initialText;

  EditTextPage({required this.initialText});

  @override
  _EditTextPageState createState() => _EditTextPageState();
}

class _EditTextPageState extends State<EditTextPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              // Save the edited text and pop the page
              Navigator.pop(context, _textEditingController.text);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Enter your text here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

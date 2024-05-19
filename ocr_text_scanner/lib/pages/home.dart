// home.dart

import 'package:flutter/material.dart';
import 'package:ocr_text_scanner/model/HistoryItem.dart';
import 'package:ocr_text_scanner/pages/DetailViewPage.dart';
import 'package:ocr_text_scanner/utils/HistoryProvider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:ocr_text_scanner/providers/theme_provider.dart'; // Import the ThemeProvider

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OCR Text Scanner"),
        actions: [
          // Add a theme toggle button in the app bar
          IconButton(
            icon: Icon(Provider.of<ThemeProvider>(context).currentTheme == ThemeData.light()
                ? Icons.nightlight_round // Sun icon for light theme
                : Icons.wb_sunny_outlined), // Moon icon for dark theme
            onPressed: () {
              // Call the toggleTheme method from ThemeProvider
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        color: Theme.of(context).scaffoldBackgroundColor, // Use theme color for background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),
            Text(
              "Language: English",
              style: TextStyle(
                  color: Color(0xFF8B828D), // Change text color to white
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, historyProvider, child) {
                  // Use the history list provided by the HistoryProvider
                  final historyList = historyProvider.history;
                  return ListView.builder(
                    itemCount: historyList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final historyItem = historyList[index];
                      String? formattedTime = _formatDateTime(_parseDateTime(historyItem.time));
                      String firstLine = historyItem.firstLine.split('\n').first;
                      return Dismissible(
                        key: Key(historyItem.time),
                        onDismissed: (direction) {
                          // Remove the item from the history list when dismissed
                          historyProvider.removeFromHistory(index);
                        },
                        background: Container(
                          color: Colors.red,
                          child: Icon(Icons.delete),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                        ),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              firstLine,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedTime ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailViewPage(historyItem: historyItem),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundImage: FileImage(File(historyItem.imagePath)),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100, // Adjust the width as needed
        child: FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, '/upload');
          },
          child: Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.add),
              SizedBox(width: 10), // Add some spacing between the icon and text
              Text('New'), // Add the text
            ],
          ),
        ),
      ),

    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString != null) {
      try {
        return DateTime.parse(dateTimeString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

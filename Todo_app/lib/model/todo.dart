import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import FirebaseAuth

class ToDo {
  final String id;
  final String? userId; // Add userId property
  String todoText;
  DateTime? date;
  TimeOfDay? time;
  bool isDone;
  final bool repeatDaily;
  final String? instanceId; // Add instanceId property

  ToDo({
    required this.id,
    this.userId,
    required this.todoText,
    this.date,
    this.time,
    required this.isDone,
    required this.repeatDaily,
    this.instanceId,
  });

  // Factory method to create a ToDo object from a Firestore document
  factory ToDo.fromFirestore(DocumentSnapshot doc, User currentUser) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ToDo(
      id: doc.id,
      userId: currentUser.uid, // Use the current user's UID
      todoText: data['todoText'],
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      time: data['time'] != null ? _timeFromJson(data['time']) : null,
      isDone: data['isDone'],
      repeatDaily: data['repeatDaily'],
    );
  }

  // Method to convert a ToDo object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'todoText': todoText,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'time': time != null ? _timeToJson(time!) : null,
      'isDone': isDone,
      'repeatDaily': repeatDaily,
    };
  }

  // Convert TimeOfDay to a string for Firestore
  static String _timeToJson(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute}';
  }

  // Convert a string from Firestore to TimeOfDay
  static TimeOfDay _timeFromJson(String timeString) {
    final parsedTime = TimeOfDay(
        hour: int.parse(timeString.split(':')[0]),
        minute: int.parse(timeString.split(':')[1]));
    return parsedTime;
  }

  static List<ToDo> todoList() {
    return [
      // Return your initial todo list here if needed
    ];
  }
}

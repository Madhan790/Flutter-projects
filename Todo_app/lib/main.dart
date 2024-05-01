import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/LoginScreen.dart';
import 'package:todo_app/screens/UserDetails.dart';
import 'package:todo_app/screens/home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();

  // Initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBUtmAhOEBs3hWxf3v-ofX9wRgwZlva0p0",
        appId: "1:846680596445:android:7250477ea2f63dfdf16034",
        messagingSenderId: "846680596445",
        projectId: "todoapp-60895",// Your Firebase configuration options
        storageBucket: "todoapp-60895.appspot.com",
      ),
    );
  }

  // Enable Firestore offline persistence for mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  }

  List<ToDo> todoList = ToDo.todoList();
  // Call handleConnectivity function to listen for connectivity changes
  handleConnectivity(todoList);

  runApp(MyApp());
}

void handleConnectivity(List<ToDo> todoList) {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    for (var result in results) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        // Device is online, sync data with Firestore
        User? user = FirebaseAuth.instance.currentUser;
        syncDataWithFirestore(user, todoList); // Pass user and todoList here
        break; // Exit loop if any network connectivity is detected
      }
    }
  });
}

void syncDataWithFirestore(User? user, List<ToDo> todoList) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (user != null) {
      // Retrieve data from Firestore
      QuerySnapshot querySnapshot = await firestore
          .collection('todos')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Convert Firestore data to ToDo objects and update the local todoList
      List<ToDo> todos =
      querySnapshot.docs.map((doc) => ToDo.fromFirestore(doc, user)).toList();

      // Update the local todoList
      todoList.clear();
      todoList.addAll(todos);
    }
  } catch (e) {
    print('Error syncing data with Firestore: $e');
  }
}

class MyApp extends StatelessWidget {
  final List<ToDo> todoList = ToDo.todoList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo app',
      home: LoginScreen(),
      routes: {
        '/home': (context) => Home(todoList: todoList),
        '/login': (context) => LoginScreen(),
        '/userDetails': (context) => UserDetails(),
      },
    );
  }
}

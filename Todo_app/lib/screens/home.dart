import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/HistoryPage.dart';
import 'package:todo_app/screens/UserDetails.dart';
import 'package:todo_app/screens/calendar_page.dart';
import 'package:todo_app/widgets/todo_items.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';



class Home extends StatefulWidget {
  final List<ToDo> todoList;

  Home({Key? key, required this.todoList}) : super(key: key);

  @override
  State<Home> createState() => _HomeState(todoList: todoList);
}

class _HomeState extends State<Home> {
  List<ToDo> _foundToDo = [];
  List<ToDo> _completedToDo = [];
  late TextEditingController _todoController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final List<ToDo> todoList;

  File? _profileImage;
  String? _profileImageUrl;

  _HomeState({required this.todoList});


  String _getTodayInstanceId() {
    // Get today's date
    DateTime now = DateTime.now();
    // Convert to a format that Firebase can store
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    // Combine with a unique identifier to ensure uniqueness
    return 'instance_$formattedDate';
  }


  @override
  void initState() {
    fetchTodoItems(); // Call the function to fetch todo items when the widget is initialized
    _foundToDo = widget.todoList.where((todo) => !todo.isDone).toList();
    _completedToDo = widget.todoList.where((todo) => todo.isDone).toList();
    _todoController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    super.initState();


  }
// Add _fetchTodos method here
  Future<void> fetchTodoItems() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await firestore
            .collection('todos')
            .where('userId', isEqualTo: user.uid)
            .get();

        List<ToDo> todos = [];

        querySnapshot.docs.forEach((doc) {
          // Check if repeatDaily is true and include todos for all days
          if (doc['repeatDaily'] == true) {
            // Create todos for the next 30 days starting from the selected date
            for (int i = 0; i < 30; i++) {
              var newDate = doc['date'].toDate().add(Duration(days: i));
              var newTodo = ToDo(
                id: doc.id, // Use the same ID for all repeated todos
                todoText: doc['todoText'],
                date: newDate,
                time: TimeOfDay.fromDateTime(doc['date'].toDate()), // Convert date to TimeOfDay
                isDone: doc['isDone'],
                repeatDaily: doc['repeatDaily'],
              );
              todos.add(newTodo);
            }
          } else {
            // If repeatDaily is false, include the todo only for its specific date
            var todo = ToDo(
              id: doc.id,
              todoText: doc['todoText'],
              date: doc['date'].toDate(),
              time: TimeOfDay.fromDateTime(doc['date'].toDate()),
              isDone: doc['isDone'],
              repeatDaily: doc['repeatDaily'],
            );
            todos.add(todo);
          }
        });

        setState(() {
          widget.todoList.clear();
          widget.todoList.addAll(todos);
          _runFilter(''); // Refresh the filter to ensure new todos are included
        });
      }
    } catch (e) {
      print('Error fetching todo items: $e');
    }
  }










  Future<void> handleRefresh() async {
    // Fetch todo items when the user triggers a refresh action
    await fetchTodoItems();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<ToDo>> groupedToDos = _groupToDosByDate(_foundToDo);

    // Sort the keys in ascending order
    var sortedKeys = groupedToDos.keys.toList()..sort();
    var sortedMap = Map<DateTime, List<ToDo>>.fromIterable(sortedKeys, key: (k) => k, value: (k) => groupedToDos[k] ?? []);

    bool showWelcomeMessage = _foundToDo.isEmpty && _completedToDo.isEmpty;

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildMenuDrawer(context),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Column(
              children: [
                _searchBox(),
                SizedBox(height: 20),
                if (showWelcomeMessage)
                  Text(
                    'Welcome, ${_getUserName()}!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                Expanded(
                  child: _foundToDo.isEmpty
                      ? Center(
                    child: Text(
                      'Create your todos!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                      : ListView.builder(
                    itemCount: sortedMap.length,
                    itemBuilder: (context, dateIndex) {
                      DateTime date = sortedMap.keys.elementAt(dateIndex);
                      List<ToDo>? todosForDate = sortedMap[date];

                      return todosForDate != null && todosForDate.isNotEmpty
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${date.day}/${date.month}/${date.year}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          for (var todo in todosForDate)
                            TodoItems(
                              todo: todo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _deleteToDoItem,
                              onEditItem: _editToDoItem,
                            ),
                        ],
                      )
                          : SizedBox.shrink(); // Don't display anything if no todos for the date
                    },
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3E2AB),
                  Color(0xFFA9D0E3),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFECE7E7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: 'Add new todo item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showDateTimePicker();
                    },
                    child: Text('Set Time'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // Ask the user if the task should repeat daily
                      bool repeatDaily = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Repeat Daily?'),
                          content: Text('Do you want this task to repeat daily?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false); // User does not want to repeat daily
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true); // User wants to repeat daily
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                      if (repeatDaily != null) {
                        _addToDoItem(_todoController.text, _selectedDate, _selectedTime, repeatDaily);
                      }
                    },
                    child: Text('+'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAndSaveProfilePhoto() async {
    String? imageUrl = await _uploadProfilePhoto();
    if (imageUrl != null) {
      setState(() {
        _profileImage = null; // Clear the local profile image after uploading
      });
    }
  }


  Future<String?> _uploadProfilePhoto() async {
    try {
      if (_profileImage != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_photos/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putFile(_profileImage!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        return await taskSnapshot.ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<void> _updateProfilePhotoUrl(String? photoUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoUrl': photoUrl});

        // Set the profile image URL to _profileImageUrl after updating in Firestore
        setState(() {
          _profileImageUrl = photoUrl;
        });
      }
    } catch (e) {
      print('Error updating profile photo URL: $e');
    }
  }




  void _handleToDoChange(ToDo todo) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if the todo is a repeated todo
      if (todo.repeatDaily) {
        // Update only the current instance (today's todo) based on its instanceId
        await firestore.collection('todos').doc(todo.id).update({
          'isDone': true,
          // Add instanceId field to uniquely identify each instance of the repeated todo
          'instanceId': _getTodayInstanceId(), // Assuming you want to mark today's instance as completed
        });

        // Move the completed todo to the history collection
        await firestore.collection('history').add({
          'userId': todo.userId, // Assuming userId is a valid property of ToDo
          'todoText': todo.todoText,
          'date': todo.date,
          'time': '${todo.time?.hour ?? 0}:${todo.time?.minute ?? 0}', // Null check for time
          'isDone': true,
          'repeatDaily': todo.repeatDaily,
          'instanceId': todo.instanceId, // Assuming instanceId is a valid property of ToDo
        });
      } else {
        // Update the completion status of the single todo
        await firestore.collection('todos').doc(todo.id).update({
          'isDone': true,
        });

        // Move the completed todo to the history collection
        await firestore.collection('history').add({
          'userId': todo.userId, // Assuming userId is a valid property of ToDo
          'todoText': todo.todoText,
          'date': todo.date,
          'time': '${todo.time?.hour ?? 0}:${todo.time?.minute ?? 0}', // Null check for time
          'isDone': true,
          'repeatDaily': todo.repeatDaily,
        });
      }

      setState(() {
        todo.isDone = true; // Update local state
      });
    } catch (e) {
      print('Error updating todo item: $e');
    }
  }

  void _deleteToDoItem(String id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('todos').doc(id).delete();

      setState(() {
        widget.todoList.removeWhere((item) => item.id == id);
        _foundToDo.removeWhere((item) => item.id == id);
      });
    } catch (e) {
      print('Error deleting todo item: $e');
    }
  }


  void _addToDoItem(String toDo, DateTime date, TimeOfDay time, bool repeatDaily) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentReference docRef = await firestore.collection('todos').add({
          'userId': user.uid,
          'todoText': toDo,
          'date': date,
          'time': '${time.hour}:${time.minute}', // Convert TimeOfDay to string
          'repeatDaily': repeatDaily,
          'isDone': false,
        });

        // Get the ID of the newly added document
        String todoId = docRef.id;

        setState(() {
          if (repeatDaily) {
            // Create todos for the next 30 days starting from the selected date
            for (int i = 0; i < 30; i++) {
              var newDate = date.add(Duration(days: i));
              var newTodo = ToDo(
                id: todoId, // Use the same ID for all repeated todos
                todoText: toDo,
                date: newDate,
                time: time,
                isDone: false,
                repeatDaily: repeatDaily,
              );
              widget.todoList.insert(0, newTodo);
            }
          } else {
            // If repeatDaily is false, create a single todo for the specified date
            var newTodo = ToDo(
              id: todoId, // Use the same ID for the todo
              todoText: toDo,
              date: date,
              time: time,
              isDone: false,
              repeatDaily: repeatDaily,
            );
            widget.todoList.insert(0, newTodo);
          }
          _runFilter(''); // Refresh the filter to ensure new todos are included
        });
      }

      _todoController.clear(); // Clear the todo input field
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() {
        _foundToDo = widget.todoList.where((item) => !item.isDone).toList();
      });
    } else {
      setState(() {
        _foundToDo = widget.todoList
            .where((item) =>
        item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()) && !item.isDone)
            .toList();
      });
    }
  }

  void _editToDoItem(String id, String newText, DateTime date, TimeOfDay time) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('todos').doc(id).update({
        'todoText': newText,
        'date': date,
        'time': '${time.hour}:${time.minute}',
      });

      setState(() {
        var index = _foundToDo.indexWhere((item) => item.id == id);
        if (index != -1) {
          _foundToDo[index].todoText = newText;
          _foundToDo[index].date = date;
          _foundToDo[index].time = time;
        }
      });
    } catch (e) {
      print('Error editing todo item: $e');
    }
  }


  Future<void> _showDateTimePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
    // Ask the user if the task should repeat daily
    bool repeatDaily = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Repeat Daily?'),
        content: Text('Do you want this task to repeat daily?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // User does not want to repeat daily
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // User wants to repeat daily
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (repeatDaily != null) {
      setState(() {
        _addToDoItem(_todoController.text, _selectedDate, _selectedTime, repeatDaily);
      });
    }
  }
// Inside your login process after successful authentication

  void _handleSignIn(User user) {
    // Fetch the profile image URL from Firestore
    _fetchProfileImageUrl(user.uid);
  }

// Fetch profile image URL from Firestore
  Future<void> _fetchProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String? photoUrl = userDoc.get('photoUrl');

      setState(() {
        _profileImageUrl = photoUrl;
      });
    } catch (e) {
      print('Error fetching profile image URL: $e');
    }
  }



  Map<DateTime, List<ToDo>> _groupToDosByDate(List<ToDo> toDos) {
    Map<DateTime, List<ToDo>> groupedToDos = {};
    for (var todo in toDos) {
      if (todo.date != null) {
        DateTime date = DateTime(todo.date!.year, todo.date!.month, todo.date!.day);
        if (groupedToDos.containsKey(date)) {
          groupedToDos[date]!.add(todo);
        } else {
          groupedToDos[date] = [todo];
        }
      }
    }
    return groupedToDos;
  }


  Future<void> uploadFile(File file) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('assets/images/');
      await ref.putFile(file);
      print('File uploaded successfully.');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  // Add _buildProfileImageWidget method here
  Widget _buildProfileImageWidget(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (_profileImage != null) {
      // Display local profile image
      return GestureDetector(
        onTap: () {
          _showImageSelectionDialog(context);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: FileImage(_profileImage!),
        ),
      );
    } else if (_profileImageUrl != null) {
      // Display profile image from URL
      return GestureDetector(
        onTap: () {
          _showImageSelectionDialog(context);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(_profileImageUrl!),
        ),
      );
    } else if (user != null && user.photoURL != null) {
      // Display profile image from Firebase Auth user's photoURL
      return GestureDetector(
        onTap: () {
          _showImageSelectionDialog(context);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.photoURL!),
        ),
      );
    } else {
      // Display default profile image
      return GestureDetector(
        onTap: () {
          _showImageSelectionDialog(context);
        },
        child: CircleAvatar(
          radius: 20,
          child: Icon(Icons.person),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }




  void _showImageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }



  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF679CEF),
      title: Text('Todo List'),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserDetails()),
                );
              } catch (e) {
                print('Error navigating to UserDetails: $e');
              }
            },
            child: Container(
              height: 40,
              width: 40,
              child: _buildProfileImageWidget(context), // Add _buildProfileImageWidget here
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Call the method to upload and save the profile photo
      await _uploadAndSaveProfilePhoto();
    }
  }



  Drawer _buildMenuDrawer(BuildContext context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF679CEF),
              ),
              child: Text(
                'TodoList',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendar Page'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage(todoList: todoList)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage(todoList: widget.todoList)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person), // Icon for UserDetails
              title: Text('User Details'), // Title for UserDetails
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserDetails()), // Navigate to UserDetails page
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      );
    }



    void _logout(BuildContext context) async {
      try {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Sign out from Google
        await GoogleSignIn().signOut();

        // Navigate back to the login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        print('Error occurred during logout: $e');
      }
    }

    Widget _searchBox() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Color(0xFFECE7E7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: _runFilter,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(15),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, maxWidth: 25),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    String _getUserName() {
      User? user = FirebaseAuth.instance.currentUser;
      return user != null ? user.displayName ?? user.email ?? "User" : "User";
    }
  }

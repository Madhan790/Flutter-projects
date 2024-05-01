// todo_items.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart'; // Updated import path

class TodoItems extends StatefulWidget {
  const TodoItems({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    this.onDeleteItem, // Make onDeleteItem optional
    required this.onEditItem,
    this.showEditDeleteOptions = true, // Provide default value for showEditDeleteOptions
  }) : super(key: key);

  final ToDo todo;
  final Function(ToDo) onToDoChanged;
  final Function(String)? onDeleteItem; // Make onDeleteItem optional
  final Function(String, String, DateTime, TimeOfDay) onEditItem;
  final bool showEditDeleteOptions; // Provide default value for showEditDeleteOptions

  @override
  _TodoItemsState createState() => _TodoItemsState();
}

class _TodoItemsState extends State<TodoItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFECE7E7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: IconButton(
          icon: Icon(
            widget.todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.blue,
          ),
          onPressed: () {
            widget.onToDoChanged(widget.todo);
            updateTodoCompletionStatus(widget.todo); // Call method to update completion status in data source
          },
        ),
        title: Text(
          widget.todo.todoText!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            decoration: widget.todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showEditDialog();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                widget.onDeleteItem!(widget.todo.id!);
              },
            ),
          ],
        ),
        subtitle: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.todo.date != null ? DateFormat('MMM dd, yyyy').format(widget.todo.date!) : 'No Date',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.todo.time != null ? widget.todo.time!.format(context) : 'No Time',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> _showEditDialog() async {
    String newText = widget.todo.todoText!;
    DateTime newDate = widget.todo.date ?? DateTime.now();
    TimeOfDay newTime = widget.todo.time ?? TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newText = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter new text',
                ),
                controller: TextEditingController()..text = newText,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime.utc(2022, 1, 1),
                    lastDate: DateTime.utc(2100, 12, 31),
                  );
                  if (pickedDate != null) {
                    newDate = pickedDate;
                  }

                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: newTime,
                  );
                  if (pickedTime != null) {
                    newTime = pickedTime;
                  }
                  widget.onEditItem(widget.todo.id!, newText, newDate, newTime);
                  Navigator.pop(context);
                },
                child: Text('Edit Here'),
              ),
            ],
          ),
        );
      },
    );
  }
}
void updateTodoCompletionStatus(ToDo todo) {
  // Implement logic to update completion status in Firestore
  // Example:
  // Firestore.instance.collection('todos').doc(todo.id).update({
  //   'isDone': todo.isDone,
  // });
}

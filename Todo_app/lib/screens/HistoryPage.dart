import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart';
import '../widgets/todo_items.dart';

class HistoryPage extends StatefulWidget {
  final List<ToDo> todoList;

  const HistoryPage({Key? key, required this.todoList}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState(todoList: todoList);
}

class _HistoryPageState extends State<HistoryPage> {
  final List<ToDo> todoList;
  List<ToDo> _completedTodos = [];
  List<ToDo> _pendingTodos = [];

  _HistoryPageState({required this.todoList});

  @override
  void initState() {
    _completedTodos = _getCompletedTodos();
    _pendingTodos = _getPendingTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Specify the number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('History'),
          backgroundColor: Color(0xFF679CEF),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Completed (${_completedTodos.length})', // Display the count of completed todos
              ),
              Tab(
                text: 'Pending (${_pendingTodos.length})', // Display the count of pending todos
              ),
            ],
          ),
        ),
        body: Container(
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
          child: TabBarView(
            children: [
              _buildTodoList(_completedTodos),
              _buildTodoList(_pendingTodos),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<ToDo> todos) {
    Map<String, List<ToDo>> groupedTodos = {};

    // Group todos by date
    todos.forEach((todo) {
      String formattedDate = DateFormat.yMd().format(todo.date!); // Add ! here
      groupedTodos.putIfAbsent(formattedDate, () => []);
      groupedTodos[formattedDate]!.add(todo);
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: groupedTodos.entries.map((entry) {
          String date = entry.key;
          List<ToDo> todos = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                date,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: todos.map((todo) => TodoItems(
                  todo: todo,
                  onToDoChanged: (_) {}, // Empty function, as we don't need to change todos in history page
                  onDeleteItem: (_) {}, // Empty function, as we don't need to delete todos in history page
                  onEditItem: (_, __, ___, ____) {}, // Empty function, as we don't need to edit todos in history page
                )).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }


  List<ToDo> _getCompletedTodos() {
    return widget.todoList.where((todo) => todo.isDone).toList();
  }

  List<ToDo> _getPendingTodos() {
    return widget.todoList.where((todo) => !todo.isDone).toList();
  }
}

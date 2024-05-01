import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/todo.dart'; // Updated import path
import '../widgets/todo_items.dart'; // Updated import path

class CalendarPage extends StatefulWidget {
  final List<ToDo> todoList;

  const CalendarPage({Key? key, required this.todoList}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState(todoList: todoList);
}

class _CalendarPageState extends State<CalendarPage> {
  final List<ToDo> todoList;
  DateTime _focusedDay = DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
  List<ToDo> _selectedDateTodos = [];

  _CalendarPageState({required this.todoList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Color(0xFF679CEF), // Make app bar transparent
        elevation: 0, // Remove app bar elevation
      ),
      body: Stack(
        children: [
          Container(
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
          Scaffold(

            body: Container(
              color: Colors.white, // Add background color to the body
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2022, 1, 1),
                        focusedDay: _focusedDay,
                        lastDay: DateTime.now().add(Duration(days: 365)),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontSize: 20),
                          leftChevronIcon: Icon(Icons.arrow_back_ios),
                          rightChevronIcon: Icon(Icons.arrow_forward_ios),
                          titleTextFormatter: (DateTime date, dynamic format) {
                            if (format == CalendarFormat.month) {
                              return DateFormat.yMMM().format(date);
                            } else if (format == CalendarFormat.twoWeeks) {
                              return '2 Weeks';
                            } else if (format == CalendarFormat.week) {
                              return 'Week';
                            } else {
                              return DateFormat.yMMM().format(date);
                            }
                          },
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _focusedDay = selectedDay; // Update _focusedDay with the selected day
                          });
                          _showSelectedDateTodos(selectedDay); // Show todos for the selected day
                        },
                        calendarBuilders: CalendarBuilders(
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue, // Set color to indicate selection
                              ),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(color: Colors.white), // Set text color to white
                              ),
                            );
                          },
                        ),
                      ),


                      SizedBox(height: 20),
                      Text(
                        'Selected Date Todos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: _selectedDateTodos.map((todo) => TodoItems(
                          todo: todo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                          onEditItem: _editToDoItem,
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectedDateTodos(DateTime selectedDay) {
    setState(() {
      _selectedDateTodos = todoList.where((todo) {
        if (todo.date != null) {
          return todo.date!.year == selectedDay.year &&
              todo.date!.month == selectedDay.month &&
              todo.date!.day == selectedDay.day;
        }
        return false;
      }).toList();
    });
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
      _selectedDateTodos.removeWhere((item) => item.id == id);
    });
  }

  void _editToDoItem(String id, String newText, DateTime date, TimeOfDay time) {
    setState(() {
      var index = todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        todoList[index].todoText = newText;
        todoList[index].date = date;
        todoList[index].time = time;
        // Update selectedDateTodos too
        var selectedIndex = _selectedDateTodos.indexWhere((item) => item.id == id);
        if (selectedIndex != -1) {
          _selectedDateTodos[selectedIndex].todoText = newText;
          _selectedDateTodos[selectedIndex].date = date;
          _selectedDateTodos[selectedIndex].time = time;
        }
      }
      // Show updated todos for the selected date
      _showSelectedDateTodos(_focusedDay);
    });
  }
}

import 'package:clean_sample/features/task/presentation/widgets/task_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:clean_sample/features/task/presentation/views/task_manage_view.dart';

class TaskListView extends StatefulWidget { 
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  // Dummy data for UI demonstration
  final List<Map<String, dynamic>> _todos = [
    {'title': 'Buy groceries', 'description': 'Milk, Eggs, Bread', 'isCompleted': false},
    {'title': 'Meeting with team', 'description': 'Discuss project roadmap', 'isCompleted': true},
    {'title': 'Pay bills', 'description': '', 'isCompleted': false},
    {'title': 'Walk the dog', 'description': 'Take him to the park', 'isCompleted': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return TaskItemWidget(
                  title: todo['title'],
                  description: todo['description'],
                  isCompleted: todo['isCompleted'],
                  onChanged: (value) {
                    setState(() {
                      todo['isCompleted'] = value;
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskManageView()));
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

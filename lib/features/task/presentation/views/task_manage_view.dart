import 'package:flutter/material.dart';
import 'package:clean_sample/core/widgets/custom_text_field.dart';
import 'package:clean_sample/core/widgets/primary_button.dart';

class TaskManageView extends StatelessWidget {
  const TaskManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CustomTextField(label: 'Title', hint: 'What needs to be done?'),
              const SizedBox(height: 24),
              const CustomTextField(label: 'Description', hint: 'Add some details...', maxLines: 5),
              const Spacer(),
              PrimaryButton(
                text: 'Create Task',
                onPressed: () {
                  // Logic to add task would go here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

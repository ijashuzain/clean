import 'package:flutter/material.dart';

class TaskItemWidget extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final ValueChanged<bool?> onChanged;

  const TaskItemWidget({
    super.key,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: Colors.blue,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: description != null && description!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
class TaskCard extends StatelessWidget {
  final Map task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
  });

  Color priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entities = task['extracted_entities'] ?? {};
    final people = entities['people'] ?? [];
    final date = entities['date'];
    final topics = entities['topics'] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task['title'] ?? 'Untitled Task',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              /// 🔹 Paragraph (Main Input)
              Text(
                task['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),

              /// 🔹 Chips Row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(task['category'] ?? 'general'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(task['priority'] ?? 'low'),
                    backgroundColor: priorityColor(task['priority'] ?? 'low'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(task['status'] ?? 'pending'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              /// 🔹 Extracted Entities
              if (people.isNotEmpty)
                Text('👤 People: ${(people as List).join(', ')}',
                    style: const TextStyle(fontSize: 12)),
              if (date != null)
                Text('📅 Date: $date', style: const TextStyle(fontSize: 12)),
              if (topics.isNotEmpty)
                Text('🏷️ Topics: ${(topics as List).join(', ')}',
                    style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),

              /// 🔹 Suggested Actions
              if (task['suggested_actions'] != null)
                Wrap(
                  spacing: 6,
                  children: List<Widget>.from(
                    (task['suggested_actions'] as List).map(
                          (a) => Chip(
                        label: Text(a.toString()),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
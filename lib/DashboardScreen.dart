import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'TaskCard.dart';
import 'config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List tasks = [];
  bool loading = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchTasks();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/api/tasks'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tasks = data['data'];
          loading = false;
        });
        if (tasks.isNotEmpty) {
          _controller.forward();
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load tasks')));
      }
    }
  }

  Future<void> createTaskFromParagraph(String paragraph) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "title": "Auto-generated task",
          "description": paragraph,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchTasks();
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create task')),
        );
      }
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse('$BASE_URL/api/tasks/$id'));

      if (response.statusCode == 200) {
        fetchTasks();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete task')),
        );
      }
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$BASE_URL/api/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        fetchTasks();
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Smart Task Manager',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),centerTitle: true,backgroundColor: Colors.teal,),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add,color: Colors.white,),
        onPressed: () => showTaskForm(),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/3D Chef Dancing.json',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              'No tasks yet. Add one!',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: fetchTasks,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final String taskId = task['_id'] ?? task['id'] ?? '';

              return TaskCard(
                task: task,
                onDelete: () => _confirmDelete(taskId),
                onEdit: () => showEditForm(task),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteTask(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showTaskForm() {
    String paragraph = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe your task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                  'e.g. Schedule urgent meeting with team tomorrow about budget',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => paragraph = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  createTaskFromParagraph(paragraph);
                },
                child: const Text('Create Task'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void showEditForm(Map task) {
    final TextEditingController titleCtrl =
    TextEditingController(text: task['title']);
    final TextEditingController descCtrl =
    TextEditingController(text: task['description']);

    String status = (task['status'] ?? 'pending').toString().toLowerCase();
    String priority = (task['priority'] ?? 'medium').toString().toLowerCase();

    const validStatuses = ['pending', 'completed', 'in-progress'];
    if (!validStatuses.contains(status)) status = 'pending';

    const validPriorities = ['low', 'medium', 'high'];
    if (!validPriorities.contains(priority)) priority = 'medium';

    final String taskId = task['_id'] ?? task['id'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Task',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      decoration:
                      const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: validStatuses
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setModalState(() => status = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: validPriorities
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setModalState(() => priority = v!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            updateTask(taskId, {
                              "title": titleCtrl.text,
                              "description": descCtrl.text,
                              "status": status,
                              "priority": priority,
                            });
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
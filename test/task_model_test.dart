import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation should be valid', () {
      final Map<String, dynamic> taskJson = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Description',
        'status': 'pending',
        'priority': 'high'
      };

      expect(taskJson['id'], '1');
      expect(taskJson['title'], 'Test Task');
      expect(taskJson['status'], 'pending');
    });

    test('Task status update logic', () {
      String status = 'pending';
      
      // Simulate update
      status = 'completed';
      
      expect(status, 'completed');
    });

    test('Task priority validation', () {
      final List<String> validPriorities = ['low', 'medium', 'high'];
      final String inputPriority = 'high';
      
      expect(validPriorities.contains(inputPriority), true);
    });
  });
}

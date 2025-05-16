import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/models/assignment_model.dart';
import 'package:your_app/models/user_model.dart';
import 'package:your_app/models/test_model.dart';

void main() {
  group('AssignmentModel Tests', () {
    test('fromMap and toMap should work correctly', () {
      final map = {
        'title': 'Math Homework',
        'description': 'Solve problems 1-10',
        'subject': 'Math',
        'classSection': '10-A',
        'dueDate': '2025-05-20T10:00:00.000Z',
        'attachmentUrl': 'http://example.com/file.pdf',
      };

      final assignment = AssignmentModel.fromMap(map, '123');
      expect(assignment.id, '123');
      expect(assignment.title, 'Math Homework');
      expect(assignment.subject, 'Math');
      expect(
        assignment.dueDate.toUtc().toIso8601String(),
        '2025-05-20T10:00:00.000Z',
      );

      final toMap = assignment.toMap();
      expect(toMap['title'], 'Math Homework');
      expect(toMap['attachmentUrl'], 'http://example.com/file.pdf');
    });
  });

  group('UserModel Tests', () {
    test('fromMap and toMap should work correctly', () {
      final map = {
        'name': 'Alice',
        'email': 'alice@example.com',
        'role': 'teacher',
        'profileImageUrl': 'http://example.com/avatar.png',
        'phoneNumber': '1234567890',
      };

      final user = UserModel.fromMap(map, 'u1');
      expect(user.id, 'u1');
      expect(user.name, 'Alice');
      expect(user.role, 'teacher');
      expect(user.phoneNumber, '1234567890');

      final toMap = user.toMap();
      expect(toMap['email'], 'alice@example.com');
      expect(toMap['profileImageUrl'], 'http://example.com/avatar.png');
    });
  });

  group('TestModel Tests', () {
    test('fromMap and toMap should work correctly', () {
      final map = {
        'title': 'Midterm Exam',
        'subject': 'Science',
        'classSection': '12-B',
        'testDate': '2025-06-10T08:00:00.000Z',
        'gradingType': 'Marks',
        'maximumMarks': 100,
        'minimumMarks': 35,
      };

      final testModel = TestModel.fromMap(map, 't1');
      expect(testModel.id, 't1');
      expect(testModel.title, 'Midterm Exam');
      expect(testModel.gradingType, 'Marks');
      expect(testModel.maximumMarks, 100);

      final toMap = testModel.toMap();
      expect(toMap['subject'], 'Science');
      expect(toMap['minimumMarks'], 35);
    });
  });
}

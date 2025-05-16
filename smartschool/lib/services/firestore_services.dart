import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_model.dart';
import '../models/test_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- User ----------------

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> addUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // ---------------- Assignments ----------------

  Future<List<AssignmentModel>> getAssignments() async {
    final snapshot = await _db.collection('assignments').get();
    return snapshot.docs
        .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addAssignment(AssignmentModel assignment) async {
    await _db
        .collection('assignments')
        .doc(assignment.id)
        .set(assignment.toMap());
  }

  Future<void> deleteAssignment(String id) async {
    await _db.collection('assignments').doc(id).delete();
  }

  // ---------------- Tests ----------------

  Future<List<TestModel>> getTests() async {
    final snapshot = await _db.collection('tests').get();
    return snapshot.docs
        .map((doc) => TestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addTest(TestModel test) async {
    await _db.collection('tests').doc(test.id).set(test.toMap());
  }

  Future<void> deleteTest(String id) async {
    await _db.collection('tests').doc(id).delete();
  }

  // ---------------- Chat Messages ----------------

  Future<List<MessageModel>> getMessages(String chatRoomId) async {
    final snapshot =
        await _db
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  // ---------------- Report Issues ----------------

  Future<void> submitReportIssue(Map<String, dynamic> reportData) async {
    await _db.collection('reportIssues').add(reportData);
  }
}

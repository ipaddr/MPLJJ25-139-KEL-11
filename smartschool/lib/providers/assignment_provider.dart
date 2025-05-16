import 'package:flutter/material.dart';
import '../models/assignment_model.dart';
import '../services/firestore_service.dart';

class AssignmentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;

  /// Ambil semua assignment dari Firestore
  Future<void> fetchAssignments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _assignments = await _firestoreService.getAssignments();
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tambahkan assignment baru
  Future<void> addAssignment(AssignmentModel assignment) async {
    try {
      await _firestoreService.addAssignment(assignment);
      _assignments.add(assignment);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding assignment: $e');
    }
  }

  /// Hapus assignment
  Future<void> deleteAssignment(String id) async {
    try {
      await _firestoreService.deleteAssignment(id);
      _assignments.removeWhere((assignment) => assignment.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting assignment: $e');
    }
  }

  /// Reset assignment (misalnya saat logout)
  void clearAssignments() {
    _assignments = [];
    notifyListeners();
  }
}

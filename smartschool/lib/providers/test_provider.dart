import 'package:flutter/material.dart';
import '../models/test_model.dart';
import '../services/firestore_service.dart';

class TestProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TestModel> _tests = [];
  bool _isLoading = false;

  List<TestModel> get tests => _tests;
  bool get isLoading => _isLoading;

  /// Ambil data test dari Firestore
  Future<void> fetchTests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tests = await _firestoreService.getTests();
    } catch (e) {
      debugPrint('Error fetching tests: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah test baru
  Future<void> addTest(TestModel test) async {
    try {
      await _firestoreService.addTest(test);
      _tests.add(test);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding test: $e');
    }
  }

  /// Hapus test
  Future<void> deleteTest(String id) async {
    try {
      await _firestoreService.deleteTest(id);
      _tests.removeWhere((test) => test.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting test: $e');
    }
  }

  /// Reset list tests (misal saat logout)
  void clearTests() {
    _tests = [];
    notifyListeners();
  }
}

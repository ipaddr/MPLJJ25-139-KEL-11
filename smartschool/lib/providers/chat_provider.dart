import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Mendapatkan pesan untuk room tertentu
  Future<void> fetchMessages(String chatRoomId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _firestoreService.getMessages(chatRoomId);
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Kirim pesan baru
  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    try {
      await _firestoreService.sendMessage(chatRoomId, message);
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Bersihkan pesan (misalnya saat logout)
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}

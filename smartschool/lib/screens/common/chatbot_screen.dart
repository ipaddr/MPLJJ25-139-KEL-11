import 'package:flutter/material.dart';
import 'package:smartschool/services/chatbot_service.dart';
import 'package:smartschool/utils/app_constants.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final List<ChatMessage> _messages =
      []; // List untuk menyimpan objek ChatMessage
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan pesan sambutan dari chatbot saat pertama kali masuk
    _messages.add(
      ChatMessage(
        text:
            'Halo! Saya asisten virtual SmartSchool. Ada yang bisa saya bantu?',
        isUser: false,
      ),
    );
  }

  void _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();

    try {
      final response = await _chatbotService.getChatResponse(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: 'Error: ${e.toString()}', isUser: false),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSchool Chatbot AI'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatbotService.clearChatHistory();
                _messages.add(
                  ChatMessage(
                    text:
                        'Halo! Saya asisten virtual SmartSchool. Ada yang bisa saya bantu?',
                    isUser: false,
                  ),
                );
              });
            },
            tooltip: 'Mulai Percakapan Baru',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Untuk menampilkan pesan terbaru di bawah
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message =
                    _messages[_messages.length -
                        1 -
                        index]; // Ambil dari belakang
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(
                color: AppConstants.accentBlue,
                backgroundColor: AppConstants.primaryBlue[100],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppConstants.lightBlue.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null, // Multiple lines
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: AppConstants.accentBlue,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
              isUser ? AppConstants.primaryBlue[300] : AppConstants.lightBlue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 12 : 0),
            topRight: Radius.circular(isUser ? 0 : 12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

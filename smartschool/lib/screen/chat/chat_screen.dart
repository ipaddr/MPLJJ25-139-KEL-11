import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String chatPartnerName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.chatPartnerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load messages when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(
        context,
        listen: false,
      ).fetchMessages(widget.chatRoomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.chatPartnerName)),
      body: Column(
        children: [
          Expanded(
            child:
                chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      reverse: true,
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[index];
                        final isMe =
                            message.senderId ==
                            'currentUserId'; // Ganti dengan current user id dari AuthProvider
                        return _buildMessageBubble(message, isMe);
                      },
                    ),
          ),
          _buildMessageInput(chatProvider),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.blueAccent : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(message.message, style: TextStyle(color: textColor)),
          ),
          const SizedBox(height: 4),
          Text(
            message.timestamp.toLocal().toString().substring(
              11,
              16,
            ), // waktu hh:mm
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = _messageController.text.trim();
                if (text.isEmpty) return;

                final newMessage = MessageModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId:
                      'currentUserId', // Ganti dengan current user id dari AuthProvider
                  senderName: 'Me', // Bisa diambil dari data user sebenarnya
                  receiverId: widget.chatRoomId,
                  message: text,
                  timestamp: DateTime.now(),
                  isRead: false,
                );

                await chatProvider.sendMessage(widget.chatRoomId, newMessage);
                _messageController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

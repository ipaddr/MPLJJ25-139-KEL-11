import 'package:flutter/material.dart';
import 'package:smartschool2/public/utils/font_style.dart';

import '../models/user.dart';
import '../view/Chat/chat_page.dart';

class ChatHeaderWidget extends StatelessWidget {
  final List<User> users;

  const ChatHeaderWidget({required this.users, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(
            'Teachers',
            style: sfBoldStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(user: users[index]),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user.urlAvatar!),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

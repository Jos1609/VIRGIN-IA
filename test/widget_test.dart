// chat_message.dart
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  const ChatMessage({super.key, required this.text, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            const CircleAvatar(
              child: Text('B'),
            ),
          if (!isUserMessage) const SizedBox(width: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blueAccent : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (isUserMessage) const SizedBox(width: 10.0),
          if (isUserMessage)
            const CircleAvatar(
              child: Text('U'),
            ),
        ],
      ),
    );
  }
}

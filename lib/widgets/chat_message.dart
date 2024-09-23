import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final bool isLoading;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUserMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUserMessage
            ? _userMessage(context)
            : isLoading
                ? _loadingMessage(context)
                : _botMessage(context),
      ),
    );
  }

  List<Widget> _userMessage(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 142, 232, 168), // Color verde claro
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
              ),
              child: SelectableText(
                text,
                style: GoogleFonts.openSans(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _botMessage(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Color gris claro
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: SelectableText(
                text,
                style: GoogleFonts.openSans(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _loadingMessage(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Color gris claro
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 10),
                  SelectableText(
                    'Analizando...',
                    style: GoogleFonts.openSans(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

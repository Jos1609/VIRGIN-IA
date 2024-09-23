import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba/screens/login/login_page.dart';
import '../services/google_api.dart';
import '../widgets/chat_message.dart';
import '../widgets/confirm_dialog.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int?> _getUserAge() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('pacientes').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['edad'] as int?;
      }
    }
    return null;
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: message, isUserMessage: true));
        _messageController.clear();
      });

      final age = await _getUserAge();
      if (age != null) {
        final googleApiService = GoogleGenerativeApiService();
        try {
          final response = await googleApiService.getDiagnosisAndTreatment(message,age );
          final responseMessage = response['text'];

          setState(() {
            _messages.add(ChatMessage(
              text: responseMessage,
              isUserMessage: false,
            ));
          });

          // Guardar en Firebase
          final User? user = _auth.currentUser;
          if (user != null) {
            DocumentReference userDocRef = _firestore.collection('historia_clinica').doc(user.uid);
            await userDocRef.collection('consultas').add({
              'uid': user.uid,
              'mensaje_usuario': message,
              'respuesta_ia': responseMessage,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          setState(() {
            _messages.add(ChatMessage(
              text: 'Error al obtener el diagnóstico y tratamiento: $e',
              isUserMessage: false,
            ));
          });
        }
      } else {
        setState(() {
          _messages.add(const ChatMessage(
            text: 'No se pudo obtener la edad del usuario.',
            isUserMessage: false,
          ));
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final bool shouldLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: 'Cerrar sesión',
          content: '¿Estás seguro de que quieres cerrar sesión?',
          onConfirm: () async {
            await FirebaseAuth.instance.signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          },
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Color.fromARGB(255, 206, 42, 42)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/fondo.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = 16.0;
              double containerWidthFactor = 1.0;

              if (constraints.maxWidth > 600) {
                horizontalPadding = constraints.maxWidth * 0.2;
                containerWidthFactor = 0.8;
              }

              return Center(
                child: Container(
                  width: constraints.maxWidth * containerWidthFactor,
                  padding: const EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'VIRGIN-IA',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _messages[index],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Escribe tus síntomas...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:prueba/screens/login/login_page.dart';
import '../services/claude_api_service.dart';
import '../widgets/chat_message.dart';
import '../widgets/confirm_dialog.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late FlutterTts _flutterTts;
  // ignore: unused_field
  TtsState _ttsState = TtsState.stopped;
  // ignore: unused_field
  String _currentWord = '';

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }
//Uamos la extensión para convertir de texto a voz
  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();

   
    await _flutterTts.awaitSpeakCompletion(true);    
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setPitch(1.0);

    // Set handlers
    _flutterTts.setStartHandler(() {
      setState(() {
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
        _currentWord = word;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setPauseHandler(() {
      setState(() {
        _ttsState = TtsState.paused;
      });
    });

    _flutterTts.setContinueHandler(() {
      setState(() {
        _ttsState = TtsState.continued;
      });
    });
  }
  //obtener la edad del niño de la base de datos
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

  Future<void> _speak(String text) async {
    var result = await _flutterTts.speak(text);
    if (result == 1) setState(() => _ttsState = TtsState.playing);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: message, isUserMessage: true));
        _messageController.clear();
        _messages.add(const ChatMessage(
          text: 'Analizando...',
          isUserMessage: false,
          isLoading: true,
        ));
      });
      //definimos la variable edad
      final age = await _getUserAge();
      if (age != null) {
        final claudeApiService = ClaudeApiService();
        try {
          //enviamos el mensaje que contiene los sintomas y la edad del paciente
          final response = await claudeApiService.getDiagnosisAndTreatment(message, age);
          final responseMessage = response['content'][0]['text'];

          setState(() {
            _messages.removeLast(); // Remueve el mensaje de cargando
            _messages.add(ChatMessage(
              text: responseMessage,
              isUserMessage: false,
            ));
          });

          // Convertir texto a voz
          await _speak(responseMessage);

          // Guardar en Firebase
          final User? user = _auth.currentUser;
          if (user != null) {
            // Referencia al documento del usuario en la colección 'historia_clinica'
            DocumentReference userDocRef = _firestore.collection('historia_clinica').doc(user.uid);
            
            // Añadir un nuevo documento a la subcolección 'consultas' dentro del documento del usuario
            await userDocRef.collection('consultas').add({
              'uid': user.uid,
              'mensaje_usuario': message,
              'respuesta_ia': responseMessage,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          setState(() {
            _messages.removeLast(); // Remove loading message
            _messages.add(ChatMessage(
              text: 'Error al obtener el diagnóstico y tratamiento: $e',
              isUserMessage: false,
            ));
          });

          // Convertir texto de error a voz
          await _speak('Error al obtener el diagnóstico y tratamiento');
        }
      } else {
        setState(() {
          _messages.removeLast(); // Remove loading message
          _messages.add(const ChatMessage(
            text: 'No se pudo obtener la edad del usuario.',
            isUserMessage: false,
          ));
        });

        // Convertir texto de error a voz
        await _speak('No se pudo obtener la edad del usuario');
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

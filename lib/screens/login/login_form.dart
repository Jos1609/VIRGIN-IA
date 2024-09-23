import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Iniciando Sesión"),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Intentar iniciar sesión
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '${_dniController.text.trim()}@dni.com',
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Verificar en las colecciones
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('pacientes').doc(user.uid).get();
        if (doc.exists) {
          // ignore: use_build_context_synchronously
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacementNamed('/diagnosis');
        } else {
          DocumentSnapshot doc1 = await FirebaseFirestore.instance.collection('encargado').doc(user.uid).get();
          if (doc1.exists) {
            // ignore: use_build_context_synchronously
            Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacementNamed('/pacientes');
          } else {
            setState(() {
              _errorMessage = 'Usuario no encontrado en las colecciones de pacientes ni encargado';
            });
            // ignore: use_build_context_synchronously
            Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = 'El formato del correo es incorrecto.';
            break;
          case 'user-disabled':
            _errorMessage = 'El usuario ha sido deshabilitado.';
            break;
          case 'user-not-found':
            _errorMessage = 'No se encontró un usuario con ese DNI.';
            break;
          case 'wrong-password':
            _errorMessage = 'Contraseña incorrecta.';
            break;
          default:
            _errorMessage = 'Usuario o Contarseña incorrectos';
        }
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'No hay conexión a Internet. Por favor, revise su conexión e inténtelo de nuevo.';
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
    } catch (e) {
      setState(() {
        _errorMessage = 'Error durante el inicio de sesión: $e';
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el diálogo
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _dniController,
            decoration: const InputDecoration(
              labelText: 'DNI',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su DNI';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              }
              return null;
            },
          ),
          const SizedBox(height: 32.0),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              if (_formKey.currentState?.validate() ?? false) {
                _signIn();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              textStyle: const TextStyle(fontSize: 16.0),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }
}

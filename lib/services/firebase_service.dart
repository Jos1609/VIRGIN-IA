import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paciente.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> updatePatient(Paciente patient) async {
    try {
      // Actualizar datos del paciente en Firestore
      await _firestore.collection('pacientes').doc(patient.idUsuario).update({
        'nombres': patient.nombres,
        'apellidos': patient.apellidos,
        'tipo_documento': patient.tipoDocumento,
        'fechaNacimiento': patient.fechaNacimiento,
        'edad': patient.edad,
      });

      return true;
    } catch (e) {
      print('Error updating patient: $e');
      return false;
    }
  }

//elimina un paciente con su id
  Future<void> deletePaciente(String idUsuario) async {
    try {
      await _firestore.collection('pacientes').doc(idUsuario).delete();
    } catch (e) {
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  Future<User?> registerPaciente(
      Paciente paciente, BuildContext context) async {
    try {
      // Intentar crear un nuevo usuario
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: '${paciente.dni}@dni.com',
        password: paciente.dni,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Agregar datos del paciente en la colección de pacientes
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .set(paciente.toMap());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Usuario registrado y datos del paciente guardados en Firestore')));
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Intentar iniciar sesión con el usuario existente
        try {
          final existingCredential = await _auth.signInWithEmailAndPassword(
            email: '${paciente.dni}@dni.com',
            password: paciente.dni,
          );
          User? existingUser = existingCredential.user;

          if (existingUser != null) {
            // Verificar si el paciente ya está en la colección de pacientes
            DocumentSnapshot snapshot = await _firestore
                .collection('pacientes')
                .doc(existingUser.uid)
                .get();
            if (snapshot.exists) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'El usuario ya está registrado en la colección de pacientes')));
              return existingUser;
            } else {
              // Agregar datos del paciente en la colección de pacientes
              await _firestore
                  .collection('pacientes')
                  .doc(existingUser.uid)
                  .set(paciente.toMap());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Datos del paciente registrados en Firestore')));
              return existingUser;
            }
          }
        } catch (signInError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error al intentar iniciar sesión: $signInError')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de autenticación: ${e.message}')));
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al escribir en Firestore: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error desconocido: $e')));
    }
    return null;
  }
}

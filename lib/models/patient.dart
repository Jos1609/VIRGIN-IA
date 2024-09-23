//import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String uid;
  final String nombres;
  final String apellidos;
  final int edad;
  final String historiaClinica;
  final String dni;

  Patient({
    required this.uid,
    required this.nombres,
    required this.apellidos,
    required this.edad,
    required this.historiaClinica,
    required this.dni,
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String uid) {
    return Patient(
      uid: uid,
      nombres: data['nombres'] as String,
      apellidos: data['apellidos'] as String,
      edad: data['edad'] as int,
      historiaClinica: data['historia_clinica'] as String,
      dni: data['dni'] as String,
    );
  }

  factory Patient.fromMap(Map<String, dynamic> data, String documentId) {
    return Patient(
      uid: documentId,
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      edad: data['edad'] ?? 0,
      historiaClinica: data['historia_clinica'] ?? '',
      dni: data['dni'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'historia_clinica': historiaClinica,
      'dni': dni,
    };
  }
}

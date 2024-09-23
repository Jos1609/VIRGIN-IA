// paciente.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Paciente {
  final String idUsuario;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final DateTime fechaNacimiento;
  final int edad;
  final String historiaClinica;
  final String dni;

  Paciente({
    required this.idUsuario,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.fechaNacimiento,
    required this.edad,
    required this.historiaClinica,
    required this.dni,
  });
  // Método para convertir un mapa de Firebase en un objeto Paciente
  factory Paciente.fromMap(Map<String, dynamic> map, String documentId) {
    return Paciente(
      idUsuario: documentId,
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      tipoDocumento: map['tipo_documento'],
      fechaNacimiento: (map['fechaNacimiento'] as Timestamp).toDate(),
      edad: map['edad'],
      historiaClinica: map['historia_clinica'],
      dni: map['dni'],
    );
  }
    factory Paciente.fromFirestore(Map<String, dynamic> map, String documentId) {
    return Paciente(
      idUsuario: documentId,
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      tipoDocumento: map['tipo_documento'] ?? '',
      fechaNacimiento: (map['fechaNacimiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edad: map['edad'] ?? 0,
      historiaClinica: map['historia_clinica'] ?? '',
      dni: map['dni'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombres': nombres,
      'apellidos': apellidos,
      'tipo_documento': tipoDocumento,
      'fechaNacimiento': fechaNacimiento,
      'edad': edad,
      'historia_clinica': historiaClinica,
      'dni': dni,
    };
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los pacientes
  Future<List<Patient>> getPatients() async {
    var snapshot = await _db.collection('pacientes').get();
    return snapshot.docs
        .map((doc) => Patient.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Obtener un paciente por su UID
  Future<Patient?> getPatientByUID(String uid) async {
    var doc = await _db.collection('pacientes').doc(uid).get();
    return doc.exists ? Patient.fromFirestore(doc.data()!, doc.id) : null;
  }

  // Obtener la historia clínica de un paciente por su UID
  Future<List<Map<String, dynamic>>> getClinicalHistory(String uid) async {
    var snapshot = await _db
        .collection('historia_clinica')
        .doc(uid)
        .collection('consultas')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Obtener el UID de un paciente por su historia clínica
  Future<String?> getPatientUidByHistory(String historiaClinica) async {
    final patientsRef = _db.collection('pacientes');
    final querySnapshot = await patientsRef
        .where('historia_clinica', isEqualTo: historiaClinica)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Devuelve el uid del primer documento encontrado
    }
    return null;
  }

  
}

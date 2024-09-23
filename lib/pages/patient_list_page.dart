import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba/models/paciente.dart';
import 'package:prueba/screens/login/login_page.dart';
import 'package:intl/intl.dart';
import 'package:prueba/widgets/ConsultationDetailsDialog.dart';
import '../models/patient.dart';
import '../services/firestore_service.dart';
import '../widgets/patient_drawer.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/patient_edit_dialog.dart'; // Asegúrate de importar la nueva vista

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  Patient? selectedPatient;

  List<Map<String, dynamic>> clinicalHistory = [];

  void _selectPatient(Patient patient) {
    setState(() {
      selectedPatient = patient;
      _fetchClinicalHistory(patient.uid);
    });
  }

  void _fetchClinicalHistory(String uid) async {
    final history = await FirestoreService().getClinicalHistory(uid);
    setState(() {
      clinicalHistory = _filterSymptoms(history)
        ..sort((a, b) {
          final dateA = a['timestamp']?.toDate() ?? DateTime(1970);
          final dateB = b['timestamp']?.toDate() ?? DateTime(1970);
          return dateB.compareTo(dateA); // Orden descendente: más reciente primero
        });
    });
  }

  List<Map<String, dynamic>> _filterSymptoms(List<Map<String, dynamic>> history) {
    final symptomKeywords = [
      'fiebre',
      'dolor',
      'tos',
      'cansancio',
      'náuseas',
      'mareo',
      'escalofríos',
      'diarrea',
      'vómito',
      'congestión'
    ];
    return history.where((entry) {
      final message = entry['mensaje_usuario']?.toLowerCase() ?? '';
      return symptomKeywords.any((keyword) => message.contains(keyword));
    }).toList();
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

  void _showConsultationDetails(String consulta, String diagnostico) {
    showDialog(
      context: context,
      builder: (context) {
        return ConsultationDetailsDialog(
          consulta: consulta,
          diagnostico: diagnostico,
        );
      },
    );
  }

  void _showPatientEditDialog(BuildContext context, String patientId) async {
    final paciente = await _fetchPatientData(patientId);
    if (paciente != null) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return PatientEditDialog(
            paciente: paciente,
            onEdit: () {
              
            },
            onDelete: () {
              
              Navigator.pop(context);
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener los datos del paciente')),
      );
    }
  }

  Future<Paciente?> _fetchPatientData(String patientId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('pacientes').doc(patientId).get();
      if (doc.exists) {
        return Paciente.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
    return null;
  }

  Stream<DocumentSnapshot> getPacienteStream(String uid) {
    return FirebaseFirestore.instance.collection('pacientes').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        actions: [
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Color.fromARGB(255, 238, 4, 4)),
            ),
          ),
        ],
      ),
      drawer: PatientDrawer(onPatientSelected: _selectPatient),
      body: selectedPatient == null
          ? const Center(child: Text('Seleccione un paciente de la lista'))
          : StreamBuilder<DocumentSnapshot>(
              stream: getPacienteStream(selectedPatient!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var pacienteData = snapshot.data!.data() as Map<String, dynamic>?;

                if (pacienteData == null) {
                  return const Center(child: Text('Paciente no encontrado.'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos del Paciente',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombres: ${selectedPatient?.nombres ?? ''} '),
                              Text('Apellidos: ${selectedPatient?.apellidos ?? ''}'),
                              Text('Edad: ${selectedPatient?.edad ?? ''}'),
                              Text('Historia Clínica: ${selectedPatient?.historiaClinica ?? ''}'),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showPatientEditDialog(context, selectedPatient!.uid),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Historia Clínica',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      clinicalHistory.isEmpty
                          ? const Text('No hay registros de consultas.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: clinicalHistory.length,
                              itemBuilder: (context, index) {
                                final consultation = clinicalHistory[index];
                                final timestamp = consultation['timestamp'];
                                final date = timestamp != null
                                    ? DateFormat.yMMMMEEEEd('es').format(timestamp.toDate())
                                    : 'Fecha desconocida';
                                final message = consultation['mensaje_usuario'] ?? 'Sin mensaje';
                                final diagnostico = consultation['respuesta_ia'] ?? 'Sin diagnóstico';

                                return Card(
                                  child: ListTile(
                                    title: Text(date),
                                    subtitle: Text(message),
                                    onTap: () => _showConsultationDetails(message, diagnostico),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/firestore_service.dart';
import '../pages/add_paciente_page.dart';

class PatientDrawer extends StatefulWidget {
  final Function(Patient) onPatientSelected;

  const PatientDrawer({super.key, required this.onPatientSelected});

  @override
  _PatientDrawerState createState() => _PatientDrawerState();
}

class _PatientDrawerState extends State<PatientDrawer> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPatients);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await FirestoreService().getPatients();
    setState(() {
      _patients = patients;
      _filteredPatients = patients;
      _loading = false;
    });
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          final apellidoLower = patient.apellidos.toLowerCase();
          final dniLower = patient.dni.toLowerCase();
          return apellidoLower.contains(query) || dniLower.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _showAddPacienteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddPacientePage();
      },
    ).then((_) {
      _loadPatients(); // Refresh the patient list after adding a new patient
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 24.0), // Añade un espacio en blanco en la parte superior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por apellidos o DNI',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? const Center(child: Text('No se encontró ningún paciente.'))
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return ListTile(
                            title: Text("${patient.apellidos} ${patient.nombres}"),
                            subtitle: Text(patient.dni),
                            onTap: () {
                              widget.onPatientSelected(patient);
                              Navigator.pop(context); // Close the drawer
                            },
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddPacienteDialog,
              child: const Text('Agregar Paciente'),
            ),
          ),
        ],
      ),
    );
  }
}

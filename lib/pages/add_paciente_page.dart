import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class AddPacientePage extends StatefulWidget {
  const AddPacientePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddPacientePageState createState() => _AddPacientePageState();
}

class _AddPacientePageState extends State<AddPacientePage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _documentoNumeroController = TextEditingController();

  String _tipoDocumento = 'DNI';
  final List<String> _tipoDocumentoOptions = ['DNI', 'Carnet de Extranjería', 'Pasaporte'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Paciente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipoDocumento,
                items: _tipoDocumentoOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoDocumento = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de Documento'),
              ),
              TextFormField(
                controller: _documentoNumeroController,
                decoration: const InputDecoration(labelText: 'Número de Documento'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento (dd/MM/aaaa)'),
                keyboardType: TextInputType.datetime,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime now = DateTime.now();
                  DateTime fiveYearsAgo = DateTime(now.year - 12, now.month, now.day);
    
                  DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: fiveYearsAgo, // Fecha mínima establecida a 12 años antes
                  lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _fechaNacimientoController.text = DateFormat('dd/MM/yyyy').format(picked);
                    });
                  }

                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Agregar Paciente'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
void _submit() async {
  if (_formKey.currentState!.validate()) {
    DateTime fechaNacimiento =
          DateFormat('dd/MM/yyyy').parse(_fechaNacimientoController.text);
    int edad = DateTime.now().year - fechaNacimiento.year;
    String historiaClinica = _documentoNumeroController.text + _tipoDocumentoIndex().toString();

    Paciente paciente = Paciente(
      idUsuario: _documentoNumeroController.text,
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      tipoDocumento: _tipoDocumento,
      fechaNacimiento: fechaNacimiento,
      edad: edad,
      historiaClinica: historiaClinica,
      dni: _documentoNumeroController.text,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Guardando paciente..."),
            ],
          ),
        );
      },
    );

    User? user = await _firebaseService.registerPaciente(paciente, context);

    Navigator.of(context).pop(); // Cerrar el diálogo de carga

    if (user != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Éxito"),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 20),
                Text("Paciente agregado exitosamente"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo de éxito
                  Navigator.of(context).pop(); // Cerrar el formulario
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 20),
                Text("Error al agregar paciente"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo de error
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}


  int _tipoDocumentoIndex() {
    switch (_tipoDocumento) {
      case 'DNI':
        return 1;
      case 'Carnet de Extranjería':
        return 2;
      case 'Pasaporte':
        return 3;
      default:
        return 0;
    }
  }
}

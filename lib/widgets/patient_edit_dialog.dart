import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class PatientEditDialog extends StatefulWidget {
  final Paciente paciente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientEditDialog({
    super.key,
    required this.paciente,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PatientEditDialogState createState() => _PatientEditDialogState();
}

class _PatientEditDialogState extends State<PatientEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _edadController;
  late TextEditingController _historiaClinicaController;
  late TextEditingController _tipoDocumentoController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _dniController;

  String _tipoDocumento = '';
  final List<String> _tipoDocumentoOptions = [
    'DNI',
    'Carnet de Extranjería',
    'Pasaporte'
  ];

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.paciente.nombres);
    _apellidosController =TextEditingController(text: widget.paciente.apellidos);
    _edadController = TextEditingController(text: widget.paciente.edad.toString());
    _historiaClinicaController = TextEditingController(text: widget.paciente.historiaClinica);
    _tipoDocumentoController =  TextEditingController(text: widget.paciente.tipoDocumento);
    _fechaNacimientoController = TextEditingController(
  text: DateFormat('dd/MM/yyyy').format(widget.paciente.fechaNacimiento),
);

    _dniController = TextEditingController(text: widget.paciente.dni);

    _tipoDocumento = widget.paciente.tipoDocumento;
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _historiaClinicaController.dispose();
    _tipoDocumentoController.dispose();
    _fechaNacimientoController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Editar Paciente'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
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
               value: _tipoDocumento.isEmpty ? null : _tipoDocumento, 
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
                decoration:
                    const InputDecoration(labelText: 'Tipo de Documento'),
              ),
              TextFormField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: 'Número de Documento',
                  helperText: 'No se puede cambiar',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                enabled: false, // Deshabilitar la edición del campo
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento (dd/MM/aaaa)'),
                keyboardType: TextInputType.datetime,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime now = DateTime.now();
                  DateTime fiveYearsAgo =
                      DateTime(now.year - 12, now.month, now.day);

                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: widget.paciente.fechaNacimiento,
                    firstDate:
                        fiveYearsAgo, // Fecha mínima establecida a 12 años antes
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _fechaNacimientoController.text =
                          DateFormat('dd/MM/yyyy').format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.update, color: Colors.blue),
          label: const Text(
            'Actualizar',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton.icon(
          onPressed: _confirmDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      DateTime fechaNacimiento =
          DateFormat('dd/MM/yyyy').parse(_fechaNacimientoController.text);
      int edad = DateTime.now().year - fechaNacimiento.year;
      String historiaClinica =
          _dniController.text + _tipoDocumentoIndex().toString();

      Paciente pacienteActualizado = Paciente(
        idUsuario: widget.paciente.idUsuario,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        tipoDocumento: _tipoDocumento,
        fechaNacimiento: fechaNacimiento,
        edad: edad,
        historiaClinica: historiaClinica,
        dni: _dniController.text,
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
                Text("Guardando cambios..."),
              ],
            ),
          );
        },
      );

      try {
        await _firebaseService.updatePatient(pacienteActualizado);
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        Navigator.of(context).pop(); // Cerrar el diálogo de edición
        widget.onEdit(); // Llamar al callback de edición
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 20),
                  Expanded(child: Text("Error al guardar cambios: $e")),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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

  void _confirmDelete() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Está seguro de que desea eliminar este paciente?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _delete() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Eliminando paciente..."),
            ],
          ),
        );
      },
    );

    try {
      await _firebaseService.deletePaciente(widget.paciente.idUsuario);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cerrar el diálogo de carga
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cerrar el diálogo de edición
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Éxito"),
            content: const Text("Paciente eliminado con éxito."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete(); // Llamar al callback de eliminación
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar el diálogo de carga
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 20),
                Expanded(child: Text("Error al eliminar paciente: $e")),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
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

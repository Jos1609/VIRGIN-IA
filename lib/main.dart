import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prueba/pages/patient_list_page.dart';
import 'screens/login/login_page.dart';
import 'views/diagnosis_screenC.dart';
import 'pages/add_paciente_page.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
   
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),      
      
      home: const SplashHandler(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/diagnosis': (context) => const DiagnosisScreen(),
        '/registro_paciente': (context) => const AddPacientePage(),
        '/pacientes': (context) => const PatientListPage(),
      },
    );
  }
}

class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  _SplashHandlerState createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
   
    await Future.delayed(const Duration(seconds: 2)); 
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

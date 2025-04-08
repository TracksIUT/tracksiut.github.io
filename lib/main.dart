import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracks/firebase_options.dart';
import 'package:tracks/pagesWeb/1_bienvenue.dart';






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    var firebase = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instanceFor(app: firebase);
    runApp(MyApp());
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false, // Cette ligne désactive le bandeau debu
      home: bienvenueWeb(),
    );
  }
}






import 'dart:async';
import 'package:flutter/material.dart';
import 'package:winterdienst_profi/loginScreen.dart';
import 'main.dart'; // Importieren Sie hier Ihre Hauptbildschirm-Datei

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/winterdienstprofi.png'), // Ihr Logo
            SizedBox(height: 20), // Abstand zwischen Logo und Text
            Text(
              'Winterdienst-Profi',
              style: TextStyle(
                fontSize: 24, // Anpassen nach Bedarf
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Anpassen nach Bedarf
              ),
            ),
          ],
        ),
      ),
    );
  }
}

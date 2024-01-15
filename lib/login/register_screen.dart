import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:winterdienst_profi/maps/karten_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  // Zusätzliche Controller für neue Felder
  final _firmennameController = TextEditingController();
  final _leitungController = TextEditingController();
  final _mobilnummerController = TextEditingController();
  String _selectedRole = 'Fahrer'; // todo liste entwickeln

  String _emailValidationMessage = '';
  String _passwordLengthMessage = '';
  String _passwordNumberMessage = '';
  String _passwordSpecialCharMessage = '';
  String _passwordUppercaseMessage = '';
  String _confirmPasswordValidationMessage = '';

  void _updateEmailValidation() {
    final email = _emailController.text;
    if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      setState(() {
        _emailValidationMessage = 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
      });
    } else {
      setState(() {
        _emailValidationMessage = '';
      });
    }
  }

  void _updatePasswordValidations() {
    final password = _passwordController.text;
    setState(() {
      _passwordLengthMessage = password.length >= 7 ? '' : 'Mindestens 7 Zeichen';
      _passwordNumberMessage = password.contains(RegExp(r'[0-9]')) ? '' : 'Mindestens eine Zahl';
      _passwordSpecialCharMessage = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? '' : 'Mindestens ein Sonderzeichen';
      _passwordUppercaseMessage = password.contains(RegExp(r'[A-Z]')) ? '' : 'Mindestens ein Großbuchstabe';
    });
  }

  void _updateConfirmPasswordValidation() {
    setState(() {
      _confirmPasswordValidationMessage = _passwordController.text == _confirmPasswordController.text
          ? ''
          : 'Passwörter stimmen nicht überein.';
    });
  }

  void _register() async {
    _updateEmailValidation();
    if (_emailValidationMessage.isNotEmpty ||
        _passwordLengthMessage.isNotEmpty ||
        _passwordNumberMessage.isNotEmpty ||
        _passwordSpecialCharMessage.isNotEmpty ||
        _passwordUppercaseMessage.isNotEmpty ||
        _confirmPasswordValidationMessage.isNotEmpty) {
      // Zeige Fehlermeldungen oder handle den Fehler
      return;

    }

    final registrationSuccess = await _attemptRegistration();
    if (registrationSuccess) {
      _showRegistrationSuccess();
      _navigateToCardScreen();
    } else {
      _showRegistrationError();
    }

    if (registrationSuccess) {
      await _saveUserDataToFirestore();
      _showRegistrationSuccess();
      _navigateToCardScreen();
    } else {
      _showRegistrationError();
    }
  }

  Future<void> _saveUserDataToFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('benutzer');

    await users.doc(userId).set({
      'email': _emailController.text,
      'rolle': _selectedRole,
      // Weitere Benutzerdaten hier hinzufügen
    });

    if (_selectedRole == 'Firma') {
      CollectionReference firmen = FirebaseFirestore.instance.collection(_firmennameController.text);
      await firmen.doc(userId).set({
        'email': _emailController.text,
        'leitung': _leitungController.text,
        'mobilnummer': _mobilnummerController.text,
        'rolle': ['Firma', 'Fahrer', 'Kunde'] // Rollenliste anpassen
      });
    }
  }

  Future<bool> _attemptRegistration() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (kDebugMode) {
        print("Registered: ${userCredential.user}");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  void _showRegistrationSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrierung erfolgreich!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showRegistrationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fehler bei der Registrierung.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToCardScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const KartenScreen()));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Email-Eingabefeld
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _updateEmailValidation(),
                  ),
                  const SizedBox(height: 10),
                  Text(_emailValidationMessage, style: const TextStyle(color: Colors.red)),

                  // Passwort-Eingabefeld
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (value) => _updatePasswordValidations(),
                  ),
                  _buildPasswordValidationMessages(),

                  // Passwort-Wiederholung
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Passwort wiederholen',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (value) => _updateConfirmPasswordValidation(),
                  ),
                  const SizedBox(height: 10),
                  Text(_confirmPasswordValidationMessage, style: const TextStyle(color: Colors.red)),

                  // Zusätzliche Felder für Firmeninformationen
                  TextField(
                    controller: _firmennameController,
                    decoration: const InputDecoration(
                      labelText: 'Firmenname',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _leitungController,
                    decoration: const InputDecoration(
                      labelText: 'Leitung',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _mobilnummerController,
                    decoration: const InputDecoration(
                      labelText: 'Mobilnummer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown für die Rolle
                  DropdownButton<String>(
                    value: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    items: <String>['Firma', 'Fahrer', 'Kunde']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  // Registrieren-Button
                  ElevatedButton(
                    onPressed: _register,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('Registrieren'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordValidationMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_passwordLengthMessage, style: const TextStyle(color: Colors.red)),
        Text(_passwordNumberMessage, style: const TextStyle(color: Colors.red)),
        Text(_passwordSpecialCharMessage, style: const TextStyle(color: Colors.red)),
        Text(_passwordUppercaseMessage, style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}

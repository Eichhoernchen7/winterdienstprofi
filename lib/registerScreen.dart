import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:winterdienst_profi/kartenScreen.dart';
import 'package:winterdienst_profi/loginScreen.dart';
import 'package:winterdienst_profi/main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
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
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Registered: ${userCredential.user}");

      // Zeige Toast-Benachrichtigung für erfolgreiche Registrierung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrierung erfolgreich!'),
          duration: Duration(seconds: 3),
        ),
      );
      // zum Kartenscreen navigieren
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => KartenScreen()));
    } catch (e) {
      print(e); // Fehlerbehandlung
      // Optional: Zeige Toast-Benachrichtigung für einen Fehler
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler bei der Registrierung.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrieren')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _updateEmailValidation(),
            ),
            Text(_emailValidationMessage, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => _updatePasswordValidations(),
            ),
            Text(_passwordLengthMessage, style: TextStyle(color: Colors.red)),
            Text(_passwordNumberMessage, style: TextStyle(color: Colors.red)),
            Text(_passwordSpecialCharMessage, style: TextStyle(color: Colors.red)),
            Text(_passwordUppercaseMessage, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Passwort wiederholen'),
              obscureText: true,
              onChanged: (value) => _updateConfirmPasswordValidation(),
            ),
            Text(_confirmPasswordValidationMessage, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrieren'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

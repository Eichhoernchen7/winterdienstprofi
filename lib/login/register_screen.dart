import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:winterdienst_profi/maps/karten_screen.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _updateEmailValidation(),
            ),
            Text(_emailValidationMessage, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => _updatePasswordValidations(),
            ),
            Text(_passwordLengthMessage, style: const TextStyle(color: Colors.red)),
            Text(_passwordNumberMessage, style: const TextStyle(color: Colors.red)),
            Text(_passwordSpecialCharMessage, style: const TextStyle(color: Colors.red)),
            Text(_passwordUppercaseMessage, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Passwort wiederholen'),
              obscureText: true,
              onChanged: (value) => _updateConfirmPasswordValidation(),
            ),
            Text(_confirmPasswordValidationMessage, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _register,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}

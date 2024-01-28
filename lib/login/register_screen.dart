import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:winterdienst_profi/main.dart';
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
  // Hinzufügen einer Variablen für die Hintergrundfarbe des Firmennamen-Textfelds
  Color _firmennameBackgroundColor = Colors.white;
  bool _isFirmennameValid = false;
  String _selectedRole = 'Fahrer';

  String _emailValidationMessage = '';
  String _passwordLengthMessage = '';
  String _passwordNumberMessage = '';
  String _passwordSpecialCharMessage = '';
  String _passwordUppercaseMessage = '';
  String _confirmPasswordValidationMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialisieren Sie die Überprüfung des Firmennamens
    _firmennameController.addListener(_checkFirmenname);
  }

  void _checkFirmenname() async {
    if (_selectedRole != 'Fahrer') {
      setState(() {
        _firmennameBackgroundColor = Colors.blue;
        _isFirmennameValid = true; // Setzen Sie dies auf true, da die Validierung für andere Rollen nicht relevant ist
      });
      return;
    }

    String firmenname = _firmennameController.text;
    var collection = FirebaseFirestore.instance.collection(firmenname);
    var docSnapshot = await collection.limit(1).get();
    if (docSnapshot.docs.isEmpty) {
      setState(() {
        _firmennameBackgroundColor = Colors.red;
        _isFirmennameValid = false;
      });
    } else {
      setState(() {
        _firmennameBackgroundColor = Colors.green;
        _isFirmennameValid = true;
      });
    }
  }


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
      _passwordSpecialCharMessage = password.contains(RegExp(r'[!@+#$%^&*(),.?":{}|<>]')) ? '' : 'Mindestens ein Sonderzeichen';
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
    // Überprüfen Sie alle Validierungsbedingungen einschließlich der Firmennamen-Validierung
    if (_emailValidationMessage.isNotEmpty ||
        _passwordLengthMessage.isNotEmpty ||
        _passwordNumberMessage.isNotEmpty ||
        _passwordSpecialCharMessage.isNotEmpty ||
        _passwordUppercaseMessage.isNotEmpty ||
        _confirmPasswordValidationMessage.isNotEmpty ||
        !_isFirmennameValid) {
      _showFirmaNotFoundSnackBar();
      // Zeige Fehlermeldungen oder handle den Fehler
      return;
    }

    final registrationSuccess = await _attemptRegistration();
    if (registrationSuccess) {
      await _saveUserDataToFirestore();
      _showRegistrationSuccess();
      _navigateToCardScreen();
    } else {
      _showRegistrationError();
    }

  }

  Future<void> _saveUserDataToFirestore() async {
    CollectionReference companyCollection = FirebaseFirestore.instance.collection(_firmennameController.text.trim());

    if (_selectedRole == 'Firma') {
      await companyCollection.doc().set({
        'email': _emailController.text,
        'leitung': _leitungController.text,
        'mobilnummer': _mobilnummerController.text,
        'rolle': 'Firma'
      });
    } else if (_selectedRole == 'Fahrer') {
      // Holt das erste Dokument der Firma.
      var querySnapshot = await companyCollection.limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        // Nimmt die ID des ersten Dokuments.
        var firmenDocumentId = querySnapshot.docs.first.id;

        // Zugriff auf die Sub-Collection 'Fahrer'.
        CollectionReference driversCollection = companyCollection.doc(firmenDocumentId).collection('Fahrer');

        // Daten des Fahrers in der Sub-Collection speichern.
        await driversCollection.add({
          'email': _emailController.text,
          'leitung': _leitungController.text,
          'mobilnummer': _mobilnummerController.text,
          'rolle': 'Fahrer'
        });
      } else {
        // Zeigt eine Snackbar an, wenn keine Firma gefunden wurde
        _showFirmaNotFoundSnackBar();
      }
    }
  }

  void _showFirmaNotFoundSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Firma nicht gefunden. Fragen Sie Ihren Ansprechpartner nach dem korrekten Firmennamen. Achten Sie auf Groß- und Kleinschreibung.'),
        duration: Duration(seconds: 5),
      ),
    );
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MainScreen()));
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
                    decoration: InputDecoration(
                      labelText: 'Firmenname',
                      border: const OutlineInputBorder(),
                      fillColor: _firmennameBackgroundColor,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _leitungController,
                    decoration: InputDecoration(
                      labelText: _selectedRole == 'Fahrer' ? 'Dienstleistername' : 'Leitung',
                      border: const OutlineInputBorder(),
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
                        // Trigger the firm name check when the role changes
                        _checkFirmenname();
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

  @override
  void dispose() {
    _firmennameController.removeListener(_checkFirmenname);
    // Dispose andere Controller
    super.dispose();
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

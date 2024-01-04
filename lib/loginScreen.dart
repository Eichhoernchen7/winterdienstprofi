import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'kartenScreen.dart';
import 'main.dart';
import 'registerScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Logged in: ${userCredential.user}");
      // Navigieren zum Kartenscreen oder weiteren Screen nach dem Login
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MainScreen(),
      ));

      // Zeige Snackbar für erfolgreichen Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erfolgreich eingeloggt!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print(e); // Fehlerbehandlung in der Konsole
      String errorMessage = 'Fehler beim Einloggen. Bitte versuchen Sie es erneut.';

      // Überprüfen Sie, ob der Fehler eine spezifische Nachricht hat
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }

      // Zeige Snackbar für Fehlermeldung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _navigateToRegister() {
    // Navigieren zum Registrierungs-Screen
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: _navigateToRegister,
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

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'intro_screen.dart';
import 'maps/karten_screen.dart'; // Importieren Sie Ihre KartenScreen-Klasse
import 'weather/wetter_screen.dart'; // Importieren Sie Ihre WetterScreen-Klasse
// Fügen Sie weitere Imports für Ihre anderen Screens hinzu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      title: 'Winterdienst-Profi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const IntroScreen(), // Starten Sie mit dem IntroScreen
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const KartenScreen(),
    const Text('Liste'), // Ersetzen Sie dies durch Ihren Listen-Screen
    const WetterScreen(),
    const Text('Chat'), // Ersetzen Sie dies durch Ihren Chat-Screen
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: Container(
        color: Colors.black, // Schwarzer Hintergrund für den äußeren Container
        child: Container(
          margin: const EdgeInsets.only(top: 10), // Abstand nur im inneren Container
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.blue,
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Karte',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Liste',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud),
                  label: 'Wetter',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class WetterScreen extends StatefulWidget {
  const WetterScreen({super.key});

  @override
  WetterScreenState createState() => WetterScreenState();
}

class WetterScreenState extends State<WetterScreen> {
  bool isLoading = true;
  List<dynamic> wetterWarnungen = [];
  List<dynamic> wetterVorhersage = [];

  @override
  void initState() {
    super.initState();
    _loadWetterDaten();
  }

  Future<void> _loadWetterDaten() async {
    Location location = Location();
    LocationData locationData;

    try {
      locationData = await location.getLocation();

      await getWeatherWarnings(locationData.latitude!, locationData.longitude!);
      await getWeatherForecast(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      setState(() {
        wetterWarnungen =
        [{'description_de': 'Fehler beim Abrufen des Standorts: $e'}];
        wetterVorhersage = [];
        isLoading = false;
      });
    }
  }

  Future<void> getWeatherWarnings(double latitude, double longitude) async {
    var url = 'https://api.brightsky.dev/alerts?lat=$latitude&lon=$longitude';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          wetterWarnungen = data['alerts'];
          isLoading = false;
        });
      } else {
        setState(() {
          wetterWarnungen = [
            {
              'description_de': 'Fehler beim Laden der Wetterwarnungen. Status Code: ${response
                  .statusCode}'
            }
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        wetterWarnungen =
        [{'description_de': 'Fehler beim Laden der Wetterwarnungen: $e'}];
        isLoading = false;
      });
    }
  }


  Future<void> getWeatherForecast(double latitude, double longitude) async {
    var today = DateTime.now();
    var threeDaysLater = today.add(const Duration(days: 3));
    var dateFormat = DateFormat('yyyy-MM-dd');
    var url = 'https://api.brightsky.dev/weather?date=${dateFormat.format(
        today)}&last_date=${dateFormat.format(
        threeDaysLater)}&lat=$latitude&lon=$longitude&units=dwd';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          wetterVorhersage = data['weather'];
          isLoading = false;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildWarningCard(dynamic warning) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final effectiveDate = DateTime.parse(warning['effective']);
    final expiresDate = DateTime.parse(warning['expires']);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gültig von: ${dateFormat.format(effectiveDate)}',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'Bis: ${dateFormat.format(expiresDate)}',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              warning['description_de'] ?? 'Keine Beschreibung verfügbar',
              style: GoogleFonts.lato(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(dynamic weatherData) {
    final dateFormat = DateFormat('EEEE, HH:mm');
    final date = DateTime.parse(weatherData['timestamp']);
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(dateFormat.format(date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${weatherData['temperature']}°C'),
            Text('Wind: ${weatherData['wind_speed']} km/h'),
            Text('Regen: ${weatherData['precipitation']} mm'),
// Hier können Sie ein Icon einfügen, basierend auf den Wetterdaten
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        // Abstand zum oberen Bildschirmrand
        child: Column(
          children: [
            // Horizontale Liste für Wettervorhersage
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wetterVorhersage.length,
                itemBuilder: (context, index) {
                  return _buildWeatherCard(wetterVorhersage[index]);
                },
              ),
            ),

            // Liste der Wetterwarnungen
            Expanded(
              child: ListView.builder(
                itemCount: wetterWarnungen.length,
                itemBuilder: (context, index) {
                  return _buildWarningCard(wetterWarnungen[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: WetterScreen()));
}
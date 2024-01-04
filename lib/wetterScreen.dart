import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class WetterScreen extends StatefulWidget {
  @override
  _WetterScreenState createState() => _WetterScreenState();
}

class _WetterScreenState extends State<WetterScreen> {
  bool isLoading = true;
  String wetterWarnungen = 'Wetterwarnungen werden geladen...';

  @override
  void initState() {
    super.initState();
    _loadWetterWarnungen();
  }

  Future<void> _loadWetterWarnungen() async {
    Location location = new Location();
    LocationData _locationData;

    _locationData = await location.getLocation();
    await getWeatherWarnings(_locationData.latitude!, _locationData.longitude!);
  }

  Future<void> getWeatherWarnings(double latitude, double longitude) async {
    // Hier sollten Sie die DWD-API-Endpunkt URL einfügen
    var url = 'https://s3.eu-central-1.amazonaws.com/app-prod-static.warnwetter.de/v16';
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          wetterWarnungen = response.body; // Angenommen, die API liefert direkt lesbaren Text
          isLoading = false;
        });
      } else {
        setState(() {
          wetterWarnungen = 'Fehler beim Laden der Wetterwarnungen.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        wetterWarnungen = 'Fehler beim Laden der Wetterwarnungen: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text(wetterWarnungen),
      ),
    );
  }
}

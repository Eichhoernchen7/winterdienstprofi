import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class KartenScreen extends StatefulWidget {
  const KartenScreen({super.key});

  @override
  KartenScreenState createState() => KartenScreenState();
}

class KartenScreenState extends State<KartenScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  Marker? traktorMarker;
  bool isFirma = false; // Zustand, ob der Benutzer eine Firma ist

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    _checkUserRole(); // Überprüfen Sie die Benutzerrolle beim Start
  }

  void _createMarkerImageFromAsset(BuildContext context) async {
  }

  // Methode zum Abrufen der Benutzerrolle aus Firestore
  void _checkUserRole() async {
    // todo Firmennamen und id holen
    // Beispiel: Ersetzen Sie "IhrFirmenname" durch den tatsächlichen Firmennamen und passen Sie den Pfad an Ihre Datenstruktur an
    final firestoreInstance = FirebaseFirestore.instance;
    final userRoleDocument = await firestoreInstance.collection('IhrFirmenname').doc('autogenerierteID').get();

    if (userRoleDocument.exists && userRoleDocument.data()?['rolle'] == 'Firma') {
      setState(() {
        isFirma = true; // Benutzer ist eine Firma
      });
    }
  }
  // Methode zum Vorladen eines Kartenbereichs
  void preloadMapArea() {
    final LatLngBounds preloadBounds = LatLngBounds(
      southwest: const LatLng(47.220835,5.318406), // Südwest-Ecke
      northeast: const LatLng(55.013680,16.591112), // Nordost-Ecke
    );
    mapController.moveCamera(CameraUpdate.newLatLngBounds(preloadBounds, 50));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _locateMe();
    preloadMapArea();
  }

  void _locateMe() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 20.0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Hintergrundfarbe des äußeren Containers
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Hintergrundfarbe des inneren Containers
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                mapType: MapType.normal, // Oder ein anderer Karten-Typ nach Wahl
                myLocationEnabled: true, // Nutzerstandort anzeigen
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0.0, 0.0), // Standardposition, anpassen nach Bedarf
                  zoom: 15.0,
                ),
              ),
            ),
          ),
          if (isFirma) // Bedingte Anzeige des Buttons für Firmenbenutzer
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Hier die Logik zum Anlegen eines neuen Winterdienstobjekts implementieren
                  // Zum Beispiel: Navigieren zu einem anderen Bildschirm/Formular
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

}

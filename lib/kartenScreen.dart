import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:winterdienst_profi/wetterScreen.dart';

class KartenScreen extends StatefulWidget {
  @override
  _KartenScreenState createState() => _KartenScreenState();
}

class _KartenScreenState extends State<KartenScreen> {
  int _currentIndex = 0; // Aktueller Index für die BottomNavigationBar
  late GoogleMapController mapController;
  Location location = new Location();
  Marker? traktorMarker;

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
  }

  void _createMarkerImageFromAsset(BuildContext context) async {
    final ImageConfiguration imageConfiguration =
    createLocalImageConfiguration(context);
  }
  // Methode zum Vorladen eines Kartenbereichs
  void preloadMapArea() {
    final LatLngBounds preloadBounds = LatLngBounds(
      southwest: LatLng(47.220835,5.318406), // Südwest-Ecke
      northeast: LatLng(55.013680,16.591112), // Nordost-Ecke
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

  void _onItemTapped(int index) {
    if (index == 2) { // Index 2 steht für das Wetter-Icon
      Navigator.push(context, MaterialPageRoute(builder: (context) => WetterScreen()));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: new Container(
        decoration: BoxDecoration(
        color: Colors.black, // Hintergrundfarbe des Containers
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
       ),
      child: ClipRRect(
      borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
      ),
      child: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.satellite,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(0.0, 0.0), // Standardposition
            zoom: 15.0,
            ),
          ),
        ),
      ),
    );
  }
}

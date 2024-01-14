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

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
  }

  void _createMarkerImageFromAsset(BuildContext context) async {
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
      color: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
        color: Colors.black, // Hintergrundfarbe des Containers
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

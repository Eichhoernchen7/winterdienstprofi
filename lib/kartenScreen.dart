import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _locateMe();
  }

  void _locateMe() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        traktorMarker = Marker(
          markerId: MarkerId('traktor'),
          position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        );
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _getBody(_currentIndex),
        bottomNavigationBar: Container(
          color: Colors.black,
          padding: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.blue, // Setzen Sie hier den Hintergrund auf Blau
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.blue, // Weiß für ausgewählte Items
              unselectedItemColor: Colors.black, // Weiß mit Transparenz für nicht ausgewählte Items
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


  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black, // Hintergrundfarbe des Containers
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          margin: EdgeInsets.only(bottom: 20), // Raum zwischen Karte und anderen Widgets
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
        );
      case 1:
        return Text('Liste');
      case 2:
        return Text('Wetter');
      case 3:
        return Text('Chat');
      default:
        return GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.satellite,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(0.0, 0.0), // Standardposition
            zoom: 15.0,
          ),
        );
    }
  }

}

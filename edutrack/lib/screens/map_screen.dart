import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(28.6139, 77.2090), // New Delhi
    zoom: 12,
  );

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('delhi'),
      position: LatLng(28.6139, 77.2090),
      infoWindow: InfoWindow(title: 'Marker in New Delhi'),
    ),
  };

  GoogleMapController? _mapController;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() => _locationEnabled = true);
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map')),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        markers: _markers,
        onMapCreated: (c) => _mapController = c,
        myLocationEnabled: _locationEnabled,
        myLocationButtonEnabled: _locationEnabled,
        zoomControlsEnabled: true,
      ),
    );
  }
}

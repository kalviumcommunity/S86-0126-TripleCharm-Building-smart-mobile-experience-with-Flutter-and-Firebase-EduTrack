import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:edutrack/services/location_service.dart';
import 'package:edutrack/models/location_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  
  // UI state variables
  Position? _userPosition;
  Set<Marker> _markers = {};
  CameraPosition? _initialCameraPosition;
  bool _isLoading = true;
  bool _isTrackingEnabled = false;
  String _statusMessage = 'Initializing...';

  // Location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  final Set<LatLng> _routePoints = {};
  Set<Polyline> _polylines = {};

  // Sample destinations for demonstration
  late final List<LocationMarker> _sampleDestinations;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permission
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          _statusMessage = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _statusMessage = 'Could not fetch location';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userPosition = position;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _statusMessage = 'Location loaded successfully';
        _isLoading = false;
      });

      // Add initial user marker
      await _addUserMarker();

      // Setup sample destinations
      _setupSampleDestinations();

      // Add destination markers
      await _addDestinationMarkers();
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupSampleDestinations() {
    _sampleDestinations = [
      LocationMarker(
        id: 'destination1',
        title: 'School Building A',
        description: 'Main academic building',
        latitude: _userPosition!.latitude + 0.001,
        longitude: _userPosition!.longitude + 0.001,
        markerType: MarkerType.destination,
      ),
      LocationMarker(
        id: 'destination2',
        title: 'Library',
        description: 'Central library',
        latitude: _userPosition!.latitude - 0.001,
        longitude: _userPosition!.longitude + 0.002,
        markerType: MarkerType.checkpoint,
      ),
      LocationMarker(
        id: 'destination3',
        title: 'Sports Ground',
        description: 'Athletic field',
        latitude: _userPosition!.latitude + 0.002,
        longitude: _userPosition!.longitude - 0.001,
        markerType: MarkerType.checkpoint,
      ),
    ];
  }

  /// Add user's current location as a marker
  Future<void> _addUserMarker() async {
    if (_userPosition == null) return;

    final userMarker = Marker(
      markerId: const MarkerId('userData'),
      position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      infoWindow: const InfoWindow(
        title: 'You are here',
        snippet: 'Current location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.add(userMarker);
    });
  }

  /// Add destination markers to the map
  Future<void> _addDestinationMarkers() async {
    for (final destination in _sampleDestinations) {
      final marker = destination.toMarker(
        icon: destination.markerType?.getDefaultColor(),
      );
      setState(() {
        _markers.add(marker);
      });
    }
  }

  /// Toggle live location tracking
  void _toggleLocationTracking() {
    if (_isTrackingEnabled) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  /// Start tracking user location in real-time
  void _startTracking() {
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User position not available')),
      );
      return;
    }

    setState(() {
      _isTrackingEnabled = true;
      _statusMessage = 'Tracking enabled...';
    });

    // Listen to position stream
    _positionStreamSubscription = _locationService
        .getPositionStream(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          intervalDuration: 1000,
        )
        .listen(
          (Position position) {
            _updateUserLocation(position);
          },
          onError: (e) {
            print('Error tracking location: $e');
            setState(() {
              _statusMessage = 'Tracking error: $e';
            });
            _stopTracking();
          },
        );
  }

  /// Stop tracking user location
  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _isTrackingEnabled = false;
      _statusMessage = 'Tracking disabled';
    });
  }

  /// Update user location and route
  void _updateUserLocation(Position position) {
    final newLatLng = LatLng(position.latitude, position.longitude);

    // Add to route points
    _routePoints.add(newLatLng);

    // Update markers
    _markers.removeWhere((m) => m.markerId.value == 'userData');
    _markers.add(
      Marker(
        markerId: const MarkerId('userData'),
        position: newLatLng,
        infoWindow: const InfoWindow(
          title: 'You are here',
          snippet: 'Current location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Update polyline to show route
    if (_routePoints.length > 1) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePoints.toList(),
          color: Colors.blue,
          width: 5,
          geodesic: true,
        ),
      );
    }

    // Animate camera to follow user
    _mapController.animateCamera(
      CameraUpdate.newLatLng(newLatLng),
    );

    setState(() {
      _userPosition = position;
      _statusMessage =
          'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    });
  }

  /// Calculate and show distance to a destination
  Future<void> _calculateDistance(LocationMarker destination) async {
    if (_userPosition == null) return;

    final distance = LocationService.calculateDistance(
      startLatitude: _userPosition!.latitude,
      startLongitude: _userPosition!.longitude,
      endLatitude: destination.latitude,
      endLongitude: destination.longitude,
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Distance Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To: ${destination.title}'),
              const SizedBox(height: 8),
              Text('Distance: ${(distance / 1000).toStringAsFixed(2)} km'),
              const SizedBox(height: 8),
              Text('${distance.toStringAsFixed(0)} meters'),
              if (destination.description != null) ...[
                const SizedBox(height: 8),
                Text('Info: ${destination.description}'),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  /// Recenter map on user's current location
  Future<void> _recenterMap() async {
    if (_userPosition == null) return;

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          zoom: 17,
        ),
      ),
    );
  }

  /// Clear the route
  void _clearRoute() {
    setState(() {
      _routePoints.clear();
      _polylines.clear();
      _statusMessage = 'Route cleared';
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Map Markers'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage),
                ],
              ),
            )
          : _userPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(_statusMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _statusMessage = 'Retrying...';
                          });
                          _initializeMap();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Google Map
                    GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: _initialCameraPosition ??
                          const CameraPosition(
                            target: LatLng(0, 0),
                            zoom: 12,
                          ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                      mapType: MapType.normal,
                    ),

                    // Status and Control Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ),

                    // Control Buttons
                    Positioned(
                      bottom: 24,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Recenter button
                          FloatingActionButton(
                            heroTag: 'recenter',
                            mini: true,
                            onPressed: _recenterMap,
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.my_location),
                          ),
                          const SizedBox(height: 8),
                          // Clear route button
                          FloatingActionButton(
                            heroTag: 'clear',
                            mini: true,
                            onPressed: _clearRoute,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Control Panel
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tracking Toggle
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Real-time Tracking',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Switch(
                                    value: _isTrackingEnabled,
                                    onChanged: (_) =>
                                        _toggleLocationTracking(),
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            // Destinations List
                            if (_sampleDestinations.isNotEmpty)
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 150),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _sampleDestinations.length,
                                  itemBuilder: (context, index) {
                                    final destination =
                                        _sampleDestinations[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: _getMarkerColor(
                                            destination.markerType),
                                      ),
                                      title: Text(destination.title),
                                      subtitle: Text(
                                          destination.description ?? ''),
                                      onTap: () =>
                                          _calculateDistance(destination),
                                      trailing: const Icon(Icons.arrow_forward),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Color _getMarkerColor(MarkerType? type) {
    switch (type) {
      case MarkerType.destination:
        return Colors.green;
      case MarkerType.checkpoint:
        return Colors.blue;
      case MarkerType.warning:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

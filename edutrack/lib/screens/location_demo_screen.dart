import 'package:flutter/material.dart';
import 'package:edutrack/services/location_service.dart';
import 'package:edutrack/models/location_marker.dart';

/// Example screen demonstrating location service usage
class LocationDemoScreen extends StatefulWidget {
  const LocationDemoScreen({Key? key}) : super(key: key);

  @override
  State<LocationDemoScreen> createState() => _LocationDemoScreenState();
}

class _LocationDemoScreenState extends State<LocationDemoScreen> {
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;
  String _result = 'Ready to fetch location...';
  List<String> _locationHistory = [];
  double? _currentLat;
  double? _currentLng;

  /// Example 1: Get current position
  Future<void> _getCurrentPosition() async {
    setState(() {
      _isLoading = true;
      _result = 'Fetching current position...';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      
      if (position != null) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _result = '''
Current Position:
Latitude: ${position.latitude.toStringAsFixed(6)}
Longitude: ${position.longitude.toStringAsFixed(6)}
Accuracy: ${position.accuracy.toStringAsFixed(2)} meters
Altitude: ${position.altitude.toStringAsFixed(2)} meters
Speed: ${position.speed.toStringAsFixed(2)} m/s
          ''';
          _locationHistory.insert(
            0,
            'Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          );
        });
      } else {
        setState(() {
          _result = 'Failed to get location. Check permissions.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Example 2: Calculate distance between two points
  void _calculateDistance() {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch current position first')),
      );
      return;
    }

    // Calculate distance to a sample location (e.g., center of campus)
    const double destLat = 0.0; // Replace with actual destination
    const double destLng = 0.0;

    final distance = LocationService.calculateDistance(
      startLatitude: _currentLat!,
      startLongitude: _currentLng!,
      endLatitude: destLat,
      endLongitude: destLng,
    );

    setState(() {
      _result = '''
Distance Calculation:
From: ($_currentLat, $_currentLng)
To: ($destLat, $destLng)
Distance: ${(distance / 1000).toStringAsFixed(2)} km
Distance: ${distance.toStringAsFixed(0)} meters
      ''';
      _locationHistory.insert(
        0,
        'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
      );
    });
  }

  /// Example 3: Calculate bearing
  void _calculateBearing() {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch current position first')),
      );
      return;
    }

    const double destLat = 0.0;
    const double destLng = 0.0;

    final bearing = LocationService.calculateBearing(
      startLatitude: _currentLat!,
      startLongitude: _currentLng!,
      endLatitude: destLat,
      endLongitude: destLng,
    );

    setState(() {
      _result = '''
Bearing Calculation:
From: ($_currentLat, $_currentLng)
To: ($destLat, $destLng)
Bearing: ${bearing.toStringAsFixed(2)}°
      ''';
      _locationHistory.insert(
        0,
        'Bearing: ${bearing.toStringAsFixed(2)}°',
      );
    });
  }

  /// Example 4: Open location settings
  Future<void> _openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Example 5: Create and display markers
  void _demonstrateMarkers() {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch current position first')),
      );
      return;
    }

    // Create sample markers
    final markers = [
      LocationMarker(
        id: 'user',
        title: 'User Location',
        description: 'Your current position',
        latitude: _currentLat!,
        longitude: _currentLng!,
        markerType: MarkerType.standard,
      ),
      LocationMarker(
        id: 'dest1',
        title: 'Destination 1',
        description: 'Sample destination',
        latitude: _currentLat! + 0.001,
        longitude: _currentLng! + 0.001,
        markerType: MarkerType.destination,
      ),
      LocationMarker(
        id: 'checkpoint1',
        title: 'Checkpoint 1',
        description: 'Sample checkpoint',
        latitude: _currentLat! - 0.001,
        longitude: _currentLng! + 0.001,
        markerType: MarkerType.checkpoint,
      ),
    ];

    setState(() {
      _result = '''
Markers Created: ${markers.length}

${markers.map((m) => '📍 ${m.title}\n   Lat: ${m.latitude.toStringAsFixed(6)}\n   Lng: ${m.longitude.toStringAsFixed(6)}\n   Type: ${m.markerType.toString()}').join('\n\n')}
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Service Examples'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Display Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Data:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getCurrentPosition,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Get Position'),
                          style:
                              ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoading ? null : _demonstrateMarkers,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Show Markers'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _calculateDistance,
                          icon: const Icon(Icons.straighten),
                          label: const Text('Distance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _calculateBearing,
                          icon: const Icon(Icons.navigation),
                          label: const Text('Bearing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 3
                  ElevatedButton.icon(
                    onPressed: _openLocationSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Location Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),

            // Location History
            if (_locationHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'History:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _locationHistory.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              _locationHistory[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Information Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features Demonstrated:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Get current GPS position (latitude/longitude)'),
                  const Text('2. Calculate distance between two coordinates'),
                  const Text('3. Calculate bearing between two points'),
                  const Text('4. Create and manage location markers'),
                  const Text('5. Request and handle location permissions'),
                  const Text('6. Open device location settings'),
                  const SizedBox(height: 16),
                  const Text(
                    'Next Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('✓ Navigate to Map Screen to see markers on a map'),
                  const Text('✓ Enable real-time tracking to follow location updates'),
                  const Text('✓ Integrate with Firebase Firestore for location history'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:geolocator/geolocator.dart';

/// A service class for handling location-related operations
/// This includes requesting permissions, getting current position, and streaming location updates
class LocationService {
  
  /// Singleton instance
  static final LocationService _instance = LocationService._internal();

  LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission from the user
  /// Returns true if permission is granted
  Future<bool> requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      // Open app settings
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  /// Get the current position of the user
  /// [desiredAccuracy] - The desired accuracy level (default: high)
  /// Returns a Position object with latitude and longitude
  Future<Position?> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  }) async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('Permission denied, cannot get location');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get a stream of location updates
  /// This allows real-time tracking of user position
  /// [accuracy] - The desired accuracy level (default: high)
  /// [distanceFilter] - Minimum distance in meters to trigger an update (default: 5)
  /// [intervalDuration] - Interval for updates in milliseconds (default: 1000)
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
    int intervalDuration = 1000,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: Duration(milliseconds: intervalDuration),
        forceLocationManager: false,
      ),
    );
  }

  /// Calculate the distance between two coordinates in meters
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Reverse geocode a position to get address (requires additional setup)
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Note: Geolocator doesn't directly support reverse geocoding
      // You would typically use geocoding package or Google Maps API
      // This is a placeholder for implementation
      return 'Latitude: $latitude, Longitude: $longitude';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Get bearing between two coordinates (in degrees)
  static double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

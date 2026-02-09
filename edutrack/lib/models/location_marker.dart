import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model class for location markers
class LocationMarker {
  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final MarkerType? markerType;

  LocationMarker({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.markerType = MarkerType.standard,
  });

  /// Convert to Google Maps Marker
  Marker toMarker({BitmapDescriptor? icon}) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        snippet: description,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
    );
  }

  @override
  String toString() => 'LocationMarker(id: $id, title: $title, lat: $latitude, lng: $longitude)';
}

/// Enum for different marker types
enum MarkerType {
  standard,
  destination,
  checkpoint,
  warning,
  custom,
}

/// Extension to get marker color based on type
extension MarkerTypeExtension on MarkerType {
  BitmapDescriptor getDefaultColor() {
    switch (this) {
      case MarkerType.destination:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case MarkerType.checkpoint:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case MarkerType.warning:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case MarkerType.custom:
      case MarkerType.standard:
        return BitmapDescriptor.defaultMarker;
    }
  }
}

/// Model class for tracking user location with timestamp
class UserLocationSnapshot {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final DateTime timestamp;

  UserLocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.timestamp,
  });

  @override
  String toString() => 'UserLocation(lat: $latitude, lng: $longitude, acc: $accuracy)';
}

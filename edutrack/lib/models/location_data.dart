import 'package:cloud_firestore/cloud_firestore.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  // Convert to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address ?? '',
      'timestamp': timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create from Firestore document
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
    );
  }

  // GeoPoint for Firestore
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

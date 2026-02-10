import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/study_item_providers.dart';

class ItemsMapView extends ConsumerStatefulWidget {
  const ItemsMapView({Key? key}) : super(key: key);

  @override
  ConsumerState<ItemsMapView> createState() => _ItemsMapViewState();
}

class _ItemsMapViewState extends ConsumerState<ItemsMapView> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final itemsWithLocationAsyncValue =
        ref.watch(itemsWithLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Locations Map'),
      ),
      body: itemsWithLocationAsyncValue.when(
        data: (items) {
          // Create markers from items with locations
          Set<Marker> markers = {};
          LatLngBounds? bounds;

          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            if (item.location != null) {
              final position = LatLng(
                item.location!.latitude,
                item.location!.longitude,
              );

              // Update bounds
              if (bounds == null) {
                bounds = LatLngBounds(
                  southwest: position,
                  northeast: position,
                );
              } else {
                bounds = LatLngBounds(
                  southwest: LatLng(
                    bounds.southwest.latitude < position.latitude
                        ? bounds.southwest.latitude
                        : position.latitude,
                    bounds.southwest.longitude < position.longitude
                        ? bounds.southwest.longitude
                        : position.longitude,
                  ),
                  northeast: LatLng(
                    bounds.northeast.latitude > position.latitude
                        ? bounds.northeast.latitude
                        : position.latitude,
                    bounds.northeast.longitude > position.longitude
                        ? bounds.northeast.longitude
                        : position.longitude,
                  ),
                );
              }

              markers.add(
                Marker(
                  markerId: MarkerId(item.id),
                  position: position,
                  infoWindow: InfoWindow(
                    title: item.title,
                    snippet: item.description,
                  ),
                  onTap: () => _showItemDetails(context, item),
                ),
              );
            }
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create study items with locations first',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (bounds?.southwest.latitude ?? 0 +
                        (bounds?.northeast.latitude ?? 0)) /
                    2,
                (bounds?.southwest.longitude ?? 0 +
                        (bounds?.northeast.longitude ?? 0)) /
                    2,
              ),
              zoom: 14,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading map',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (item.location != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latitude: ${item.location!.latitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Longitude: ${item.location!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

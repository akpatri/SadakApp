import 'package:flutter/material.dart';
import 'package:open_route_service/open_route_service.dart';

class RouteListView extends StatelessWidget {
  final ORSCoordinate source;
  final ORSCoordinate destination;

  const RouteListView({
    super.key,
    required this.source,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Routes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoordinateCard(
              title: "Source",
              latitude: source.latitude,
              longitude: source.longitude,
            ),
            const SizedBox(height: 16),
            _buildCoordinateCard(
              title: "Destination",
              latitude: destination.latitude,
              longitude: destination.longitude,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Route Results",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Placeholder for your route list
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.alt_route),
                      title: Text("Route Option ${index + 1}"),
                      subtitle: const Text("Estimated time • Distance"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateCard({
    required String title,
    required double latitude,
    required double longitude,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Lat: $latitude"),
                Text("Lng: $longitude"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

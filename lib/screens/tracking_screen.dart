import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter:
            LatLng(-3.626815900508238, 114.86090063597713), // Center the map over London
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          // Display map tiles from any source
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
          userAgentPackageName: 'com.example.app',
          maxNativeZoom:
              5, // Scale tiles when the server doesn't support higher zoom levels
          // And many more recommended properties!
        ),
        const MarkerLayer(
          markers: [
            Marker(
              point: LatLng(-3.626815900508238, 114.86090063597713),
              height: 50.0,
              width: 50.0,
              child: Icon(Icons.location_pin)
            )
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class BankTrashLocation extends StatefulWidget {
  const BankTrashLocation({super.key});

  @override
  State<BankTrashLocation> createState() => _BankTrashLocationState();
}

class _BankTrashLocationState extends State<BankTrashLocation> {
  LatLng? userLocation;

  final List<LatLng> bankSampahLocations = [
    LatLng(-0.4804559004719885, 117.11968370723329),
    LatLng(-0.527144597580918, 117.12605437742955),
    LatLng(-0.5132568178050773, 117.11278936930238),
    LatLng(-0.5239896626350476, 117.16178084438452),
    LatLng(-0.5124815238979722, 117.17717749066017),
    LatLng(-1.276081549882546, 116.81678403132277),
    LatLng(-1.222697399203393, 116.81378919368986),
    LatLng(-1.2229778550844326, 116.81755544970791),
    LatLng(-1.2271993905257226, 116.81909498283444),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: userLocation!,
        initialZoom: 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.yourapp',
        ),
        MarkerLayer(
          markers:
              bankSampahLocations.map((location) {
                return Marker(
                  point: location,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FindStaffScreen extends StatefulWidget {
  const FindStaffScreen({super.key});

  @override
  _FindStaffScreenState createState() => _FindStaffScreenState();
}

class _FindStaffScreenState extends State<FindStaffScreen> {
  final _userLocation = Position(
    latitude: 40.7128,
    longitude: -74.0060,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  final List<Map<String, dynamic>> _staff = [
    {
      'location': Position(
        latitude: 40.7130,
        longitude: -74.0055,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
      'name': 'John Doe',
      'role': 'Manager',
    },
    {
      'location': Position(
        latitude: 40.7125,
        longitude: -74.0070,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
      'name': 'Jane Smith',
      'role': 'Assistant',
    },
    {
      'location': Position(
        latitude: 40.7140,
        longitude: -74.0040,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
      'name': 'Alice Johnson',
      'role': 'Technician',
    },
  ];

  Map<String, dynamic>? _nearestStaff;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _findNearestStaff();
  }

  Future<void> _findNearestStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? closestStaff;
      double? minDistance;

      for (var staff in _staff) {
        final distance = Geolocator.distanceBetween(
          _userLocation.latitude,
          _userLocation.longitude,
          staff['location'].latitude,
          staff['location'].longitude,
        );

        if (minDistance == null || distance < minDistance) {
          minDistance = distance;
          closestStaff = {
            'name': staff['name'],
            'role': staff['role'],
            'location': staff['location'],
            'distance': distance,
          };
        }
      }

      setState(() {
        _nearestStaff = closestStaff;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error finding staff: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[
      Marker(
        point: LatLng(_userLocation.latitude, _userLocation.longitude),
        width: 80,
        height: 80,
        child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      ),
    ];

    for (var staff in _staff) {
      final isNearest =
          _nearestStaff != null && staff['name'] == _nearestStaff!['name'];

      markers.add(
        Marker(
          point: LatLng(
            staff['location'].latitude,
            staff['location'].longitude,
          ),
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_on,
            color: isNearest ? Colors.green : Colors.blue,
            size: 35,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(_userLocation.latitude, _userLocation.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Find Nearest Staff')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                  ),
                  if (_nearestStaff != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Nearest: ${_nearestStaff!['name']} (${_nearestStaff!['role']}) - '
                        '${(_nearestStaff!['distance'] / 1000).toStringAsFixed(2)} km away',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findNearestStaff,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mansoor_task/controller/map_controller.dart';
import 'package:mansoor_task/view/trip_summary_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  static const double earthRadiusKm = 6371.0;
  final Set<Polyline> _polylines = {};
  LatLng? _startLocation;
  LatLng? _endLocation;

  void _showTripSummary() async {
    // Ensure both start and end locations are available
    if (_startLocation != null && _endLocation != null) {
      // Record the start time when the trip begins
      DateTime tripStartTime = DateTime.now();

      // Fetch addresses for start and end locations
      String startAddress = await _fetchAddress(_startLocation!, true);
      String endAddress = await _fetchAddress(_endLocation!, false);

      // Record the end time when the trip ends
      DateTime tripEndTime = DateTime.now();

      if (!mounted) return;
      showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        context: context,
        builder: (context) {
          return TripSummaryScreen(
            startLocation: startAddress,
            endLocation: endAddress,
            distanceInKm: _calculateDistance(),
            startTime: tripStartTime,
            endTime: tripEndTime,
          );
        },
      );
    }
  }

  double _calculateDistance() {
    double lat1 = _startLocation!.latitude;
    double lon1 = _startLocation!.longitude;
    double lat2 = _endLocation!.latitude;
    double lon2 = _endLocation!.longitude;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveStartMarkerToDestination();
        },
        child: const Icon(Icons.directions),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _showTripSummary,
              icon: const Text('Trip Summary'),
            ),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(25.276987, 55.296249), zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polylines: _polylines,
        onTap: (LatLng position) {
          _updateMarkers(position);
        },
      ),
    );
  }

  void _updateMarkers(LatLng position) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = position;
      } else if (_endLocation == null) {
        _endLocation = position;
        _drawRoute(); // Draw route when end location is set
      } else {
        _startLocation = position;
        _endLocation = null;
        _markers.clear();
      }
      _updateMarkersSet();
    });
  }

  void _updateMarkersSet() {
    _markers.clear();
    if (_startLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: _startLocation!,
        infoWindow: const InfoWindow(
          title: 'Start Location',
          snippet: 'Fetching address...',
        ),
      ));
      _fetchAddress(_startLocation!, true);
    }
    if (_endLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: _endLocation!,
        infoWindow: const InfoWindow(
          title: 'End Location',
          snippet: 'Fetching address...',
        ),
      ));
      _fetchAddress(_endLocation!, false);
    }
  }

  Future<String> _fetchAddress(LatLng position, bool isStartLocation) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = placemark.name ?? placemark.street ?? placemark.locality ?? 'Unknown';
        setState(() {
          if (isStartLocation) {
            _markers.removeWhere((marker) => marker.markerId.value == 'start');
            _markers.add(
              Marker(
                markerId: const MarkerId('start'),
                position: _startLocation!,
                infoWindow: InfoWindow(
                  title: 'Start Location',
                  snippet: address,
                ),
              ),
            );
          } else {
            _markers.removeWhere((marker) => marker.markerId.value == 'end');
            _markers.add(
              Marker(
                markerId: const MarkerId('end'),
                position: _endLocation!,
                infoWindow: InfoWindow(
                  title: 'End Location',
                  snippet: address,
                ),
              ),
            );
          }
        });
        return address;
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return 'Unknown';
  }

  void _drawRoute() async {
    if (_startLocation != null && _endLocation != null) {
      final String url =
          'http://router.project-osrm.org/route/v1/driving/${_startLocation!.latitude},'
          '${_startLocation!.longitude};${_endLocation!.latitude},${_endLocation!.longitude}'
          '?overview=false&steps=true';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['routes'] != null && data['routes'].isNotEmpty) {
          final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
          for (var step in steps) {
            String geometry = step['geometry'];
            List<LatLng> points = _decodePolyline(geometry);
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: points,
                  color: Colors.blue,
                  width: 5,
                ),
              );
            });
          }
        }
      }
    }
  }

  void _moveStartMarkerToDestination() async {
    if (_startLocation != null && _endLocation != null) {
      final GoogleMapController controller = await _controller.future;
      final double latDiff = (_endLocation!.latitude - _startLocation!.latitude) / 100;
      final double lngDiff = (_endLocation!.longitude - _startLocation!.longitude) / 100;
      for (int i = 0; i < 100; i++) {
        final LatLng newLocation = LatLng(
          _startLocation!.latitude + latDiff * i,
          _startLocation!.longitude + lngDiff * i,
        );
        setState(() {
          _markers.removeWhere((marker) => marker.markerId.value == 'start');
          _markers.add(Marker(markerId: const MarkerId('start'), position: newLocation));
        });
        controller.animateCamera(CameraUpdate.newLatLng(newLocation));
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  List<LatLng> _decodePolyline(String encodedPolyline) {
    List<PointLatLng> decodedPolylinePoints = PolylinePoints().decodePolyline(encodedPolyline);
    List<LatLng> polyline = decodedPolylinePoints
        .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
        .toList();
    return polyline;
  }
}

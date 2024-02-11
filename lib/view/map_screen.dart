import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mansoor_task/controller/map_controller.dart';
import 'package:mansoor_task/view/trip_summary_screen.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});

  final MapController controller = Get.put(MapController());

  /* final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  static const double earthRadiusKm = 6371.0;*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.moveStartMarkerToDestination();
        },
        child: const Icon(Icons.directions),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: controller.showTripSummary,
              icon: const Text('Trip Summary'),
            ),
          )
        ],
      ),
      body: Obx(() => GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: LatLng(25.276987, 55.296249), zoom: 14),
            onMapCreated: (GoogleMapController controller) {
              Get.find<MapController>().setMapController(controller);
            },
            markers: Set<Marker>.from(Get.find<MapController>().markers),
            onTap: controller.updateMarkers,
          )),
    );
  }
}

/* void _updateMarkers(LatLng position) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = position;
      } else if (_endLocation == null) {
        _endLocation = position;
        // _drawPolyLine();
      } else {
        _startLocation = position;
        _endLocation = null;
        // _markers.clear();
        // _polylines.clear();
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
      _fetchAddress(_startLocation!, true); // Fetch address for start location
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
      _fetchAddress(_endLocation!, false); // Fetch address for end location
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

  void _moveStartMarkerToDestination() async {
    if (_startLocation != null && _endLocation != null) {
      final GoogleMapController controller = await _controller.future;
      // Calculate the difference in latitude and longitude
      final double latDiff = (_endLocation!.latitude - _startLocation!.latitude) /
          100; // Change this value to adjust the speed
      final double lngDiff = (_endLocation!.longitude - _startLocation!.longitude) /
          100; // Change this value to adjust the speed

      for (int i = 0; i < 100; i++) {
        // Update marker position gradually
        final LatLng newLocation = LatLng(
          _startLocation!.latitude + latDiff * i,
          _startLocation!.longitude + lngDiff * i,
        );
        setState(() {
          _markers.clear();
          _markers.add(Marker(markerId: const MarkerId('start'), position: newLocation));
          _markers.add(Marker(markerId: const MarkerId('end'), position: _endLocation!));
        });
        // Animate camera to follow marker movement
        controller.animateCamera(CameraUpdate.newLatLng(newLocation));
        // Delay to create animation effect
        await Future.delayed(
            const Duration(milliseconds: 200)); // Adjust this value to change animation speed
      }
    }
  }*/

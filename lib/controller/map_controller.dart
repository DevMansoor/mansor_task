import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../view/trip_summary_screen.dart';

class MapController extends GetxController {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final RxSet<Marker> _markers = <Marker>{}.obs;
  static const double earthRadiusKm = 6371.0;

  final Rx<LatLng?> _startLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> _endLocation = Rx<LatLng?>(null);

  // Getters for startLocation and endLocation
  LatLng? get startLocation => _startLocation.value;

  LatLng? get endLocation => _endLocation.value;

  // Getter method for markers
  RxSet<Marker> get markers => _markers;

  void setMapController(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void showTripSummary() async {
    if (startLocation != null && endLocation != null) {
      DateTime tripStartTime = DateTime.now();
      String startAddress = await _fetchAddress(startLocation!, true);
      String endAddress = await _fetchAddress(endLocation!, false);
      DateTime tripEndTime = DateTime.now();

      Get.bottomSheet(
        TripSummaryScreen(
          startLocation: startAddress,
          endLocation: endAddress,
          distanceInKm: _calculateDistance(),
          startTime: tripStartTime,
          endTime: tripEndTime,
        ),
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
      );
    }
  }

  double _calculateDistance() {
    double lat1 = startLocation!.latitude;
    double lon1 = startLocation!.longitude;
    double lat2 = endLocation!.latitude;
    double lon2 = endLocation!.longitude;

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

  void updateMarkers(LatLng position) {
    if (_startLocation.value == null) {
      _startLocation.value = position;
    } else if (_endLocation.value == null) {
      _endLocation.value = position;
    } else {
      _startLocation.value = position;
      _endLocation.value = null;
    }
    _updateMarkersSet();
  }

  void _updateMarkersSet() {
    _markers.clear();
    if (_startLocation.value != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startLocation.value!,
          infoWindow: const InfoWindow(
            title: 'Start Location',
            snippet: 'Fetching address...',
          ),
        ),
      );
      _fetchAddress(_startLocation.value!, true); // Fetch address for start location
    }
    if (_endLocation.value != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _endLocation.value!,
          infoWindow: const InfoWindow(
            title: 'End Location',
            snippet: 'Fetching address...',
          ),
        ),
      );
      _fetchAddress(_endLocation.value!, false); // Fetch address for end location
    }
    update(); // Notify listeners about the changes
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
        if (isStartLocation) {
          _markers.removeWhere((marker) => marker.markerId.value == 'start');
          _markers.add(
            Marker(
              markerId: const MarkerId('start'),
              position: _startLocation.value!,
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
              position: _endLocation.value!,
              infoWindow: InfoWindow(
                title: 'End Location',
                snippet: address,
              ),
            ),
          );
        }
        update(); // Notify listeners about the changes
        return address;
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return 'Unknown';
  }

  void moveStartMarkerToDestination() async {
    if (startLocation != null && endLocation != null) {
      final GoogleMapController controller = await _controller.future;
      final double latDiff = (endLocation!.latitude - startLocation!.latitude) / 100;
      final double lngDiff = (endLocation!.longitude - startLocation!.longitude) / 100;

      for (int i = 0; i < 100; i++) {
        final LatLng newLocation = LatLng(
          startLocation!.latitude + latDiff * i,
          startLocation!.longitude + lngDiff * i,
        );
        _markers.clear();
        controller.animateCamera(CameraUpdate.newLatLng(newLocation));
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}

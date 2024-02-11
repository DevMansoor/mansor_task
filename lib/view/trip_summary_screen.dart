import 'package:flutter/material.dart';

class TripSummaryScreen extends StatelessWidget {
  final String startLocation;
  final String endLocation;
  final double distanceInKm;
  final DateTime startTime;
  final DateTime endTime;

  const TripSummaryScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.distanceInKm,
    required this.startTime,
    required this.endTime,
  });

  String formatTime(DateTime time) {
    int hour = time.hour % 12;
    String period = time.hour < 12 ? 'AM' : 'PM';
    hour = hour == 0 ? 12 : hour;

    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate trip duration
    Duration tripDuration = endTime.difference(startTime);
    String formattedStartTime = formatTime(startTime);
    String formattedEndTime = formatTime(endTime);

    // Calculate trip cost
    double tripCost = distanceInKm * 2; // Rate of 2 AED per kilometer

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Start Location: $startLocation',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'End Location: $endLocation',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'Distance: ${distanceInKm.toStringAsFixed(2)} km',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'Start Time: $formattedStartTime',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'End Time: $formattedEndTime',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'Duration: ${tripDuration.inSeconds} seconds',
            style: const TextStyle(fontSize: 18.0),
          ),
          const Divider(),
          Text(
            'Cost: ${tripCost.toStringAsFixed(2)} AED',
            style: const TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}

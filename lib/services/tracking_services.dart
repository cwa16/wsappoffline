import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TrackingService extends ChangeNotifier {
  Database? _database;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> initializeDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    _database = await openDatabase(path, version: 1);
  }

  void startTracking(int tripId) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request permissions.');
    }

    // Listen to location updates and save coordinates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1),
    ).listen((Position position) async {
      print('New position: ${position.latitude}, ${position.longitude}');
      await _saveCoordinate(tripId, position.latitude, position.longitude);
    });

    _isTracking = true;
    notifyListeners();
  }

 

  Future<void> _saveCoordinate(int tripId, double lat, double lng) async {
    if (_database == null) {
      await initializeDb();
    }

    print('Saving coordinate: tripId=$tripId, lat=$lat, lng=$lng');

    await _database!.insert(
      'coordinates', // Ensure you have a `coordinates` table
      {
        'trip_id': tripId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> stopTracking() async {
    if (_positionStreamSubscription != null) {
      print('stopping tracking....');
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _isTracking = false;
      notifyListeners();
      print('Tracking Stopped');
    } else {
      print('no active tracking');
    }
  }

  bool isTracking() {
    return _isTracking;
  }
}

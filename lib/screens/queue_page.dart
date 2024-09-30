import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class QueuePage extends StatefulWidget {
  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  Database? _database;
  List<Map<String, dynamic>> unsentTrips = [];

  @override
  void initState() {
    super.initState();
    _loadUnsentTrips();
  }

  Future<void> _loadUnsentTrips() async {
    if (_database == null) {
      var databasePath = await getDatabasesPath();
      String path = join(databasePath, 'my_database.db');

      _database = await openDatabase(path, version: 1);
    }

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      'SELECT * FROM trips WHERE is_upload = 0',
    );

    setState(() {
      unsentTrips = result;
    });
  }

  Future<List<Map<String, dynamic>>> _loadCoordinates(int tripId) async {
    final List<Map<String, dynamic>> coordinates = await _database!.query(
      'coordinates',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );

    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unsent Trips Queue"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadUnsentTrips();
          });
        },
        child: ListView.builder(
          itemCount: unsentTrips.length,
          itemBuilder: (context, index) {
            final trip = unsentTrips[index];
            return ListTile(
              title: Text('Trip ID: ${trip['id']}'),
              subtitle: Text('Destination: ${trip['destination']}'),
              trailing: IconButton(
                icon: const Icon(Icons.cloud_upload),
                onPressed: () async {
                  // check connection
                  var connectivityResult = await Connectivity().checkConnectivity();

                  if (connectivityResult == ConnectivityResult.none) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tidak terhubung Wi-Fi atau Internet'))
                    );
                    return;
                  }
                  // Add logic to upload the trip to the API
                  // String url =
                  //     'http://192.168.99.6:9090/api/store-driver-offline';
                  String url =
                      'https://bskp.blog:9001/api/store-driver-offline';

                  try {
                    // Load coordinates related to this trip
                    List<Map<String, dynamic>> coordinates =
                        await _loadCoordinates(trip['id']);

                    // Create a mutable copy of the trip data
                    Map<String, dynamic> tripData = Map.from(trip);

                    // Add coordinates to the mutable trip data
                    tripData['coordinates'] = coordinates.map((coordinate) {
                      return {
                        'latitude': coordinate['latitude'],
                        'longitude': coordinate['longitude'],
                        'timestamp': coordinate['timestamp'],
                      };
                    }).toList();

                    print("trip: $tripData");

                    http.post(
                      Uri.parse(url),
                      headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      },
                      body: jsonEncode({
                        'heavy_equipment_id': trip['heavy_equipment_id'],
                        'nik': trip['nik'],
                        'activity': trip['activity'],
                        'start': trip['start'],
                        'destination': trip['destination'],
                        'finish': trip['finish'],
                        'start_hour': trip['start_hour'],
                        'finish_hour': trip['finish_hour'],
                        'remark': trip['remark'],
                        'coordinates': tripData
                      }),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data terkirim ke server!')),
                    );

                    await _database!.update(
                      'trips',
                      {'is_upload': 1},
                      where: 'id = ?',
                      whereArgs: [trip['id']],
                    );

                    setState(() {
                      _loadUnsentTrips();
                    });
                  } catch (e) {
                    // Handle exception (e.g., network error)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

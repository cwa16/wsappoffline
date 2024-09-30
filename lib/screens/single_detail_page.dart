import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wsappoffline/screens/home_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SingleDetailPage(
      tripId: 0,
    ),
  ));
}

class SingleDetailPage extends StatefulWidget {
  final int tripId;

  const SingleDetailPage({super.key, required this.tripId});

  @override
  State<SingleDetailPage> createState() => _SingleDetailPageState();
}

class _SingleDetailPageState extends State<SingleDetailPage> {
  Database? _database;

  List<Map<String, dynamic>> loadTrip = [];

  String calculateDuration(String start, String finish) {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateFormat format2 = DateFormat("yyyy-MM-ddTHH:mm:ss.SS");
    DateTime startTime = format.parse(start);
    DateTime finishTime = format2.parse(finish);

    Duration duration = finishTime.difference(startTime);

    String formattedDuration = '${duration.inHours} jam, ${duration.inMinutes % 60} menit';
    return formattedDuration;
  }

  // Initialize the SQLite Database
  Future<void> _initializeDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE users(id INTEGER PRIMARY KEY, nik TEXT, name TEXT, password TEXT, is_login INTEGER)''',
        );

        await db.execute('''CREATE TABLE IF NOT EXISTS trips(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nik TEXT,
          heavy_equipment_id INTEGER,
          activity TEXT,
          start TEXT,
          destination TEXT,
          start_hour TEXT,
          finish_hour TEXT,
          remark TEXT,
          is_upload INTEGER,
          FOREIGN KEY (nik) REFERENCES users(nik),
          FOREIGN KEY (heavy_equipment_id) REFERENCES heavy_equipment(id)
        )''');
      },
    );

    _loadTrip();
  }

  Future<void> _loadTrip() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      '''
        SELECT trips.*,trips.id AS id_trip, heavy_equipment.name AS equipment_name, heavy_equipment.image_path AS equipment_image
      FROM trips
      JOIN heavy_equipment ON trips.heavy_equipment_id = heavy_equipment.id
      WHERE id_trip = ?
     ''',
      [widget.tripId],
    );
    
    if (result.isNotEmpty) {
      setState(() {
        loadTrip = result;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(// Replace with your actual URL or asset
              radius: 20,
            ),
            const SizedBox(height: 20),
            Image.asset(loadTrip[0]['equipment_image']!), // Ensure you have this asset in your project
            const SizedBox(height: 8),
            Text(
              '${loadTrip[0]['equipment_name']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${loadTrip[0]['activity']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              '(${loadTrip[0]['start_hour']}) ${loadTrip[0]['start']} ------- ${loadTrip[0]['finish']} (${loadTrip[0]['finish_hour']})',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              '${calculateDuration(loadTrip[0]['start_hour'], loadTrip[0]['finish_hour'])}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // full-width button
                  ),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

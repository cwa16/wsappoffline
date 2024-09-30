import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wsappoffline/screens/home_page.dart';
import 'package:wsappoffline/services/tracking_services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DetailPage(
      tripId: 0,
    ),
  ));
}

class DetailPage extends StatefulWidget {
  final int tripId;

  const DetailPage({super.key, required this.tripId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Database? _database;
  List<Map<String, dynamic>> tripsDataOngoing = [];
  String? nik; // Example NIK, replace with actual logged-in

  bool isTracking = false;

  // final TrackingService _trackingService = TrackingService();
  final mapController = MapController();

  String? selectedPerjalanan;

  final TextEditingController prestasi = TextEditingController();

  final List<String> perjalananOptions = [
    'G. Batu',
    'Tamiyang',
    'Peno',
    'Jaha',
    'G. Anten',
    'P. Kukup',
    'Sari Ambon',
    'Luar Area BSKP',
  ];

  // Initialize the SQLite Database
  Future<void> _initializeDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nik = prefs.getString('nik');
    });

    _loadTripsOngoing();
  }

  // Load the trips data based on NIK and include heavy equipment details
  Future<void> _loadTripsOngoing() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      '''
      SELECT trips.*, heavy_equipment.name AS equipment_name, heavy_equipment.image_path AS equipment_image,
      heavy_equipment.no_register AS equipment_no_register
      FROM trips
      JOIN heavy_equipment ON trips.heavy_equipment_id = heavy_equipment.id
      WHERE trips.nik = ? AND trips.finish_hour IS NULL
      ''',
      [nik], // Use the current user's NIK
    );
    print(nik);
    setState(() {
      tripsDataOngoing = result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDb();
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<TrackingService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                backgroundImage:
                    AssetImage("assets/profile.jpg"), // Example profile image
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    children: tripsDataOngoing.map((trip) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(trip['equipment_image']),
                      Text(
                        "No Register: ${trip['equipment_no_register']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kegiatan: ${trip['activity']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Tujuan: ${trip['destination']}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Titik Keberangkatan: ${trip['start']}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedPerjalanan,
                        decoration: InputDecoration(
                          labelText: 'Titik Selesai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: perjalananOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          selectedPerjalanan = newValue;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: prestasi,
                        decoration: InputDecoration(
                          labelText: 'contoh 3rit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_database == null) return;

                          // Make sure the 'selectedPerjalanan' and 'prestasi' fields are filled
                          if (selectedPerjalanan == null ||
                              prestasi.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill out all fields')),
                            );
                            return;
                          }

                          // Update the trip with the new data
                          await _database!.update(
                            'trips',
                            {
                              'finish_hour': DateTime.now().toIso8601String(),
                              'finish': selectedPerjalanan,
                              'remark': prestasi.text,
                              'is_upload': 0,
                            },
                            where: 'id = ?',
                            whereArgs: [widget.tripId],
                          );

                          locationService.stopTracking();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Trip updated successfully!')),
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15)),
                        child: const Text(
                          'Finish',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    ],
                  );
                }).toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

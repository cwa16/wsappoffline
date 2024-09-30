import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wsappoffline/screens/home_page.dart';
import 'package:wsappoffline/services/tracking_services.dart';

void main() {
  runApp(
    const MaterialApp(
      home: InputDataPage(result: ''),
    ),
  );
}

// ignore: must_be_immutable
class InputDataPage extends StatefulWidget {
  final String result;

  const InputDataPage({super.key, required this.result});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  // final TrackingService _trackingService = TrackingService();

  final List<String> kegiatanOptions = [
    'Angkut Kayu',
    'Angkut Air',
    'Angkut Latex',
    'Angkut & Ecer Bibit',
    'Angkut & Ecer Pupuk',
    'Angkut Material',
    'Angkut Solar',
    'Angkut Pasir & Batu',
    'Angkut Sampah',
    'Angkut Penumpang',
    'Angkut Bambu',
    'Belanja',
    'Lain-lain',
  ];

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

  final List<String> titikAwalOptions = [
    'G. Batu',
    'Tamiyang',
    'Peno',
    'Jaha',
    'G. Anten',
    'P. Kukup',
    'Sari Ambon',
    'Luar Area BSKP',
  ];

  Database? _database;

  String? selectedKegiatan;
  String? selectedPerjalanan;
  String? selectedTitikAwal;

  String? noPolisi;
  String? name;
  String? model;
  String? imagePath;
  String? assetCode;
  String? nik;

  @override
  void initState() {
    super.initState();
    _initializeDb();
  }

  // Initialize the SQLite Database
  Future<void> _initializeDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE heavy_equipment(
        id INTEGER PRIMARY KEY,
        asset_code TEXT,
        no_register TEXT,
        name TEXT,
        type TEXT,
        year INTEGER,
        condition TEXT,
        status TEXT,
        image_path TEXT
      )
      ''');

        // Create trips table if not already created
        await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nik TEXT, 
        heavy_equipment_id INTEGER, 
        activity TEXT, 
        start TEXT, 
        destination TEXT, 
        finish TEXT, 
        start_hour TEXT,
        finish_hour TEXT,
        remark TEXT,
        is_upload INTEGER,
        FOREIGN KEY (nik) REFERENCES users(nik),
        FOREIGN KEY (heavy_equipment_id) REFERENCES heavy_equipment(id)
      )
      ''');
      },
    );

    // Load the equipment once the database is initialized
    _loadEquipment();
  }

  // Function to load equipment data from the database
  Future<void> _loadEquipment() async {
    if (_database == null) return;

    List<Map<String, dynamic>> result = await _database!.query(
      'heavy_equipment',
      where: 'id = ?',
      whereArgs: [widget.result],
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If data is found, update the state to display it
    if (result.isNotEmpty) {
      setState(() {
        noPolisi = result[0]['no_register'];
        assetCode = result[0]['asset_code'];
        name = result[0]['name'];
        model = result[0]['type'];
        imagePath = result[0]['image_path'];
        nik = prefs.getString('nik');
      });
    } else {
      print('No data found for asset_code: ${widget.result}');
    }
  }

  Future<void> _saveTrip() async {}

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<TrackingService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/profile.jpg'), // Example profile image
              radius: 20,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      imagePath != null
                          ? Image.asset('${imagePath}')
                          : const Text('No data'),
                      Text(
                          'No. Polisi: ${noPolisi ?? ''}'), // Display fetched No. Polisi
                      Text('No. Aset: ${assetCode}'), // Display asset_code
                      Text('Name: ${name ?? ''}'), // Display fetched Name
                      Text('Model: ${model ?? ''}'), // Display fetched Model
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: selectedKegiatan,
                decoration: InputDecoration(
                  labelText: 'Kegiatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: kegiatanOptions.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedKegiatan = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedPerjalanan,
                decoration: InputDecoration(
                  labelText: 'Perjalanan',
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
                  setState(() {
                    selectedPerjalanan = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTitikAwal,
                decoration: InputDecoration(
                  labelText: 'Titik Awal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: titikAwalOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedTitikAwal = newValue;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Perform the submit action here
                      if (_database == null) return;
                      // Prepare the trip data
                      Map<String, dynamic> tripData = {
                        'nik': nik,
                        'heavy_equipment_id': widget
                            .result, // Assuming result is heavy_equipment ID
                        'activity': selectedKegiatan,
                        'start': selectedTitikAwal,
                        'destination': selectedPerjalanan,
                        'start_hour': DateTime.now()
                            .toString(), // Start time (you can change this to user input)
                        'finish_hour': null,
                      };

                      // Insert the trip data into the trips table
                      int tripId = await _database!.insert(
                        'trips',
                        tripData,
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );

                      print('tripId: $tripId');
                      // After submitting data, start tracking
                      // await _trackingService.startTracking(tripId);
                      locationService.startTracking(tripId);

                      print('Trip data saved successfully');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const HomePage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wsappoffline/screens/detail_page.dart';
import 'package:wsappoffline/screens/job_card.dart';
import 'package:wsappoffline/screens/qr_scanner_page.dart';
import 'package:wsappoffline/screens/queue_page.dart';
import 'package:wsappoffline/screens/single_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database? _database;
  List<Map<String, dynamic>> tripsData = [];
  List<Map<String, dynamic>> tripsDataOngoing = [];
  List<Map<String, dynamic>> usersData = [];
  String? nik; // Example NIK, replace with actual logged-in user's NIK

  @override
  void initState() {
    super.initState();
    _initializeDb(); // Initialize the database and load trips
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nik = prefs.getString('nik');
    });

    _loadTrips();
    _loadTripsOngoing();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      '''
      SELECT * FROM users
      WHERE nik = ?
     ''',
      [nik],
    );
    if (result.isNotEmpty) {
      setState(() {
        usersData = result;
      });
    }
  }

  // Load the trips data based on NIK and include heavy equipment details
  Future<void> _loadTrips() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      '''
      SELECT trips.*, heavy_equipment.name AS equipment_name, heavy_equipment.image_path AS equipment_image
    FROM trips
    JOIN heavy_equipment ON trips.heavy_equipment_id = heavy_equipment.id
    WHERE trips.nik = ?
    AND trips.finish_hour IS NOT NULL
    AND DATE(trips.start_hour) BETWEEN DATE('now', '-1 day') AND DATE('now')
      ''',
      [nik], // Use the current user's NIK
    );
    print(nik);
    setState(() {
      tripsData = result;
    });
  }

  // Load the trips data based on NIK and include heavy equipment details
  Future<void> _loadTripsOngoing() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      '''
      SELECT trips.*, heavy_equipment.name AS equipment_name, heavy_equipment.image_path AS equipment_image
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Implement menu action
          },
        ),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  child: const Text('Keluar'),
                  onTap: () {},
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile.png'),
                  // Replace with actual profile image
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _initializeDb();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang, ${usersData.isNotEmpty ? usersData[0]['name'] : 'Pengguna'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Selalu Utamakan Keselamatan Kerja',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pekerjaan Hari ini Section
                const Text(
                  'Pekerjaan Hari ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                (tripsDataOngoing.isNotEmpty)
                    ? Column(
                        children: tripsDataOngoing.map((trip) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Implement navigation to detailed trip page if necessary
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPage(tripId: trip['id'])));
                                },
                                child: JobCard(
                                  title: trip['activity'],
                                  time: trip['start_hour'],
                                  location: trip['start'],
                                  destination: trip['destination'],
                                  time_finish: trip['finish_hour'] ?? '',
                                  status: (trip['finish_hour'] != null)
                                      ? 'Selesai'
                                      : 'Ongoing', // You can customize status
                                  vehicle: trip[
                                      'equipment_name'], // Heavy equipment name
                                  imageUrl: trip[
                                      'equipment_image'], // Heavy equipment image path
                                  color: (trip['finish_hour'] != null)
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text("Mulai Pekerjaan"),
                              const SizedBox(height: 10),
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.orangeAccent,
                                child: IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 35, color: Colors.black),
                                  onPressed: () {
                                    // Implement add new job action
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const QRScanPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Data Antrian Server
                const Text(
                  'Kirim Data ke BSKPServer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => QueuePage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Cek Antrian',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Riwayat Pekerjaan Section
                const Text(
                  'Riwayat Pekerjaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Display the trips data
                Column(
                  children: tripsData.map((trip) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Implement navigation to detailed trip page if necessary
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SingleDetailPage(tripId: trip['id'])));
                          },
                          child: JobCard(
                            title: trip['activity'],
                            time: trip['start_hour'],
                            location: trip['start'],
                            destination: trip['destination'],
                            time_finish: trip['finish_hour'] ?? '',
                            status: (trip['finish_hour'] != null)
                                ? 'Selesai'
                                : 'Ongoing', // You can customize status
                            vehicle:
                                trip['equipment_name'], // Heavy equipment name
                            imageUrl: trip[
                                'equipment_image'], // Heavy equipment image path
                            color: (trip['finish_hour'] != null)
                                ? Colors.blue
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

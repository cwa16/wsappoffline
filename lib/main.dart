import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wsappoffline/screens/landing_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wsappoffline/services/tracking_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<TrackingService>(
      create: (context) => TrackingService(),
      child: const MyApp(),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();

  // initialize the db
  Database db = await initializeDb();

  // load csv
  List<List<dynamic>> csvData = await loadCSV('lib/assets/users.csv');

  // Load and import heavy equipment CSV
  List<List<dynamic>> heavyEquipmentCsvData =
      await loadHeavyEquipmentCSV('lib/assets/heavy_equipment.csv');
  await importHeavyEquipmentToDb(db, heavyEquipmentCsvData);

  // insert db
  await importCSVtoDb(db, csvData);
}

Future<List<List<dynamic>>> loadCSV(String path) async {
  final csvData = await rootBundle.loadString(path);
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);
  return csvTable;
}

Future<List<List<dynamic>>> loadHeavyEquipmentCSV(String path) async {
  final csvData = await rootBundle.loadString(path);
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);
  return csvTable;
}

Future<Database> initializeDb() async {
  var databasePath = await getDatabasesPath();
  String path = join(databasePath, 'my_database.db');

  return await openDatabase(path, version: 1, onCreate: (db, version) async {
    await db.execute(
      'CREATE TABLE users(id INTEGER PRIMARY KEY, nik TEXT, name TEXT, password TEXT, is_login INTEGER)',
    );

    // Create heavy_equipment table
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

    // Create trips table with relationships to users and heavy_equipment
    await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY,
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

    await db.execute('''
      CREATE TABLE coordinates(
        id INTEGER PRIMARY KEY,
        trip_id INTEGER,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        is_sent INTEGER DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES trips(id)
      )
    ''');
  });
}

Future<void> importCSVtoDb(Database db, List<List<dynamic>> csvData) async {
  for (var row in csvData) {
    if (row.isNotEmpty) {
      await db.insert(
        'users',
        {
          'id': row[0],
          'nik': row[1],
          'name': row[2],
          'password': row[3],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}

Future<void> importHeavyEquipmentToDb(
    Database db, List<List<dynamic>> csvData) async {
  for (var row in csvData) {
    if (row.isNotEmpty) {
      await db.insert(
        'heavy_equipment',
        {
          'id': row[0],
          'asset_code': row[1],
          'no_register': row[2],
          'name': row[3],
          'type': row[4],
          'year': row[5],
          'condition': row[6],
          'status': row[7],
          'image_path': row[8],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wsappoffline/screens/home_page.dart'; // For handling database path

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDb();
    // _checkLoginStatus();
  }

  // Future<void> _checkLoginStatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  //   if (isLoggedIn) {
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  //   }
  // }

  // Initialize the SQLite Database
  Future<void> _initializeDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, nik TEXT, name TEXT, password TEXT, is_login INTEGER)',
        );
      },
    );
  }

  // Function to validate login credentials
  Future<bool> _validateLogin(String nik, String password) async {
    if (_database == null) return false; // If the database is not initialized

    // Query the database for matching nik and password
    List<Map<String, dynamic>> result = await _database!.query(
      'users',
      where: 'nik = ? AND password = ?',
      whereArgs: [nik, password],
    );

    // Return true if a matching record is found, otherwise false
    return result.isNotEmpty;
  }

  void _login(BuildContext context) async {
    String nik = _nikController.text;
    String password = _passController.text;

    if (nik.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Please enter both NIK and password');
      return;
    }

    bool isValid = await _validateLogin(nik, password);

    if (isValid) {
      // Update is_login to 1 for the logged-in user
      await _database!.update(
        'users',
        {'is_login': 1}, // Set is_login to 1
        where: 'nik = ?',
        whereArgs: [nik], // Use the current user's NIK
      );

      _showSuccessDialog(context, 'Login successful');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('nik', nik);
      prefs.setBool('is_logged_in', true);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      _showErrorDialog(context, 'Invalid NIK or password');
    }
  }

// Function to show an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context, // Ensure this is 'context', which is a BuildContext
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

// Function to show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context, // Ensure this is 'context', which is a BuildContext
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to the next screen here
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silahkan Masuk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masukan NIK dan kata sandi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nikController,
                decoration: InputDecoration(
                  labelText: 'NIK kamu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _login(context); // Pass the context to the _login function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

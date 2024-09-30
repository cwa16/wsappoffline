import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:wsappoffline/screens/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void requestDisableBatteryOptimization() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      );
      await intent.launch();
    }
  }

  void showBatteryOptimizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disable Battery Optimization'),
          content: Text(
            'To allow the app to track your location in the background, please disable battery optimization for this app.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                requestDisableBatteryOptimization();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/tractor.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.teal,
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rencanakan Kerja Hari ini',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Buat rencana kerja dengan mudah dan akurat',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next page or perform an action
                    showBatteryOptimizationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Matikan Penghemat Baterai',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next page or perform an action

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
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
            ),
          ],
        ),
      ),
    );
  }
}

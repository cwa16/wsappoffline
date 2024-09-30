import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scanning_effect/scanning_effect.dart';
import 'package:wsappoffline/screens/input_screen.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage(
                'assets/profile.png'), // Replace with actual image asset
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Silahkan pindai QR yang terdapat pada alat berat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ScanningEffect(
                scanningColor: Colors.yellow,
                delay: const Duration(seconds: 1),
                duration: const Duration(seconds: 2),
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      // Handle the scanned data here
      if (scanData.code != null) {
        controller.pauseCamera();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputDataPage(result: scanData.code!,),
          ),
        ).then((_) {
          controller.resumeCamera();
        });
      }
      print('Scanned Data: ${scanData.code}');
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: QRScanPage(),
  ));
}

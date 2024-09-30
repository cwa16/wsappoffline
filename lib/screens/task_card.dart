import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String vehicle;

  const TaskCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.vehicle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == 'ongoing' ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Image.asset('assets/tractor.png', width: 50), // Make sure the image is in your assets
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: status == 'ongoing' ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (status == 'done')
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                vehicle,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
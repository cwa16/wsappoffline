import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String time;
  final String time_finish;
  final String location;
  final String destination;
  final String status;
  final String vehicle;
  final String imageUrl;
  final Color color;

  const JobCard({super.key, 
    required this.title,
    required this.time,
    required this.time_finish,
    required this.location,
    required this.destination,
    required this.status,
    required this.vehicle,
    required this.imageUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            imageUrl,
            height: 70.0,
            width: 70.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '($time) $location - $destination ($time_finish)',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  vehicle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
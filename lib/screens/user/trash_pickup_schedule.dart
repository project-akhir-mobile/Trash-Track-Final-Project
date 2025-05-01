import 'package:flutter/material.dart';

class TrashPickupSchedulePage extends StatelessWidget {
  const TrashPickupSchedulePage({super.key});

  final List<Map<String, String>> pickupSchedules = const [
    {
      'location': 'Samarinda Kota',
      'time': '08:00 - 10:00',
    },
    {
      'location': 'Samarinda Selatan',
      'time': '10:00 - 12:00',
    },
    {
      'location': 'Samarinda Ulu',
      'time': '12:00 - 14:00',
    },
    {
      'location': 'Samarinda Utara',
      'time': '14:00 - 16:00',
    },
    {
      'location': 'Samarinda Seberang',
      'time': '08:00 - 10:00',
    },
    {
      'location': 'Balikpapan Selatan',
      'time': '10:00 - 12:00',
    },
    {
      'location': 'Balikpapan Tengah A',
      'time': '12:00 - 13:00',
    },
    {
      'location': 'Balikpapan Tengah B',
      'time': '13:00 - 14:00',
    },
    {
      'location': 'Balikpapan Timur',
      'time': '14:00 - 16:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pickupSchedules.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white70),
      itemBuilder: (context, index) {
        final schedule = pickupSchedules[index];
        return ListTile(
          tileColor: Colors.black.withValues(alpha:  0.4), // semi-transparent background for readability
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: const Icon(Icons.location_on, color: Colors.white),
          title: Text(
            schedule['location'] ?? '',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Waktu: ${schedule['time']}',
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }
}

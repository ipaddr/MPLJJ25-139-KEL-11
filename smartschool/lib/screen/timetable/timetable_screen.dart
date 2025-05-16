import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  final List<Map<String, dynamic>> timetable = const [
    {
      'date': '30/06/2022',
      'class': 'Xth',
      'subject': 'Geography',
      'time': '4:30pm',
    },
    {
      'date': '30/06/2022',
      'class': 'XII-Rose',
      'subject': 'Economics',
      'time': '10:00pm',
    },
    {
      'date': '29/06/2022',
      'class': 'Xth',
      'subject': 'English',
      'time': '9:30am',
    },
    // Tambahkan data lainnya sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          final entry = timetable[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('${entry['subject']} - Class ${entry['class']}'),
              subtitle: Text('Date: ${entry['date']}  Time: ${entry['time']}'),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Contoh data siswa dengan status kehadiran
  final List<Map<String, dynamic>> students = [
    {'name': 'Prachi Dumyan', 'rollNo': 1, 'status': 'P'}, // P = Present
    {'name': 'Shivaay Sharma', 'rollNo': 2, 'status': 'P'},
    {'name': 'Ankit Tiwari', 'rollNo': 3, 'status': 'L'}, // L = Leave
    {'name': 'Kawaljeet Mehra', 'rollNo': 4, 'status': 'A'}, // A = Absent
    {'name': 'Amrit Kaur', 'rollNo': 5, 'status': 'P'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: CircleAvatar(child: Text(student['rollNo'].toString())),
            title: Text(student['name']),
            subtitle: Text('Roll No: ${student['rollNo']}'),
            trailing: SizedBox(
              width: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildStatusButton(student, 'P', Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusButton(student, 'L', Colors.orange),
                  const SizedBox(width: 8),
                  _buildStatusButton(student, 'A', Colors.red),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusButton(
    Map<String, dynamic> student,
    String status,
    Color color,
  ) {
    bool isSelected = student['status'] == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          student['status'] = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy, nanti bisa diganti dengan data real dari backend
    final totalStudents = 24582;
    final activeSchools = 48;
    final buildingMaintenance = 75; // persen
    final safetyCompliance = 90; // persen
    final breakfastStudents = 18245;
    final lunchStudents = 22156;
    final programCoverage = 90.2; // persen

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'All Regions School Name Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _buildStatItem('Total Students', totalStudents.toString()),
                    _buildStatItem('Active Schools', activeSchools.toString()),
                    _buildStatItem(
                      'Building Maintenance',
                      '$buildingMaintenance%',
                    ),
                    _buildStatItem('Safety Compliance', '$safetyCompliance%'),
                    _buildStatItem('Breakfast', breakfastStudents.toString()),
                    _buildStatItem('Lunch', lunchStudents.toString()),
                    _buildStatItem('Program Coverage', '$programCoverage%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: const Text('Facility Inspection Report'),
                subtitle: const Text('Central High School • 2h ago'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Navigasi ke detail laporan
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Cafeteria Health Report'),
                subtitle: const Text('East Elementary • 5h ago'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Navigasi ke detail laporan
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Maintenance Request'),
                subtitle: const Text('West Middle School • 1d ago'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Navigasi ke detail laporan
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Announcements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: const Text('Parent-Teacher Meeting'),
                subtitle: const Text('Annual PTM scheduled for May 20, 2025'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // TODO: Navigasi ke detail pengumuman
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

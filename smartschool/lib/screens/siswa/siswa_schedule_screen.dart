import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiswaScheduleScreen extends StatefulWidget {
  const SiswaScheduleScreen({super.key});

  @override
  State<SiswaScheduleScreen> createState() => _SiswaScheduleScreenState();
}

class _SiswaScheduleScreenState extends State<SiswaScheduleScreen> {
  final ApiService _apiService = ApiService();
  Map<String, List<Map<String, String>>> _schedule = {};
  bool _isLoading = true;
  UserModel? _currentUser;
  List<Map<String, dynamic>> _allClasses = []; // <<<--- Pastikan ini ada

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentUser = await _apiService.getCurrentUserData();
      _allClasses = await _apiService.getAllClasses(); // Ambil semua kelas

      String? targetClassId;
      String? targetTeacherId;

      if (_currentUser != null) {
        if (_currentUser!.role == 'siswa') {
          // Jika siswa, cari classId-nya di koleksi 'students'
          // Penting: pastikan nama siswa di koleksi 'students' cocok dengan nama di 'users'
          // atau gunakan UID untuk mencari siswa
          QuerySnapshot studentQuery =
              await FirebaseFirestore.instance
                  .collection('students')
                  .where(
                    'name',
                    isEqualTo: _currentUser!.name,
                  ) // Atau _currentUser!.id jika Anda menyimpan UID user di student doc
                  .limit(1)
                  .get();

          if (studentQuery.docs.isNotEmpty) {
            targetClassId = studentQuery.docs.first['classId'];
            print('Siswa Class ID: $targetClassId'); // Untuk debugging
          } else {
            print('Siswa document not found for user: ${_currentUser!.name}');
          }
        } else if (_currentUser!.role == 'guru') {
          // Jika guru, ambil jadwal yang dia ajar berdasarkan teacherId
          targetTeacherId = _currentUser!.id;
          print('Guru Teacher ID: $targetTeacherId'); // Untuk debugging
        }
      }

      // Panggil getSchedule dengan classId atau teacherId yang ditemukan
      _schedule = await _apiService.getSchedule(
        classId: targetClassId,
        teacherId: targetTeacherId,
      );
      print('Fetched Schedule: $_schedule'); // Untuk debugging
    } catch (e) {
      print('Error fetching schedule: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
    ]; // Urutan hari

    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Pelajaran'), // Ubah judul lebih umum
          centerTitle: true,
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children:
                      days.map((day) {
                        final dailySchedule = _schedule[day] ?? [];
                        return dailySchedule.isEmpty
                            ? Center(
                              child: Text(
                                'Tidak ada jadwal untuk $day.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: dailySchedule.length,
                              itemBuilder: (context, index) {
                                final lesson = dailySchedule[index];
                                // Dapatkan nama kelas dari ID kelas
                                String className = 'N/A';
                                if (lesson['classId'] != null) {
                                  className =
                                      _allClasses.firstWhere(
                                        (cl) => cl['id'] == lesson['classId'],
                                        orElse: () => {'name': 'N/A'},
                                      )['name'] ??
                                      'N/A';
                                }
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson['subject']!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.copyWith(
                                            color: AppConstants.darkBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              lesson['time']!,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Kelas: $className - Pengajar: ${lesson['teacher']!}', // Tampilkan kelas dan pengajar
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                      }).toList(),
                ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- Tambahkan ini
import 'package:smartschool/services/api_service.dart'; // Tambahkan ini
import 'package:smartschool/models/user_model.dart'; // Tambahkan ini
import 'package:smartschool/screens/orangtua/orangtua_progress_report_screen.dart'; // Import untuk navigasi

class GuruClassManagementScreen extends StatefulWidget {
  const GuruClassManagementScreen({super.key});

  @override
  State<GuruClassManagementScreen> createState() =>
      _GuruClassManagementScreenState();
}

class _GuruClassManagementScreenState extends State<GuruClassManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _classesData = [];
  bool _isLoading = true;
  UserModel? _currentGuru;

  @override
  void initState() {
    super.initState();
    _fetchClassesAndStudents();
  }

  Future<void> _fetchClassesAndStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentGuru = await _apiService.getCurrentUserData();
      if (_currentGuru == null) {
        print("Error: Guru user data not found.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      QuerySnapshot classSnapshot =
          await FirebaseFirestore.instance
              .collection('classes')
              .where('teacherId', isEqualTo: _currentGuru!.id)
              .get();

      List<Map<String, dynamic>> fetchedClasses = [];
      for (var classDoc in classSnapshot.docs) {
        String classId = classDoc.id;
        String className = classDoc['name'] ?? 'Unknown Class';
        List<Map<String, dynamic>> students = await _apiService
            .getStudentsInClass(classId);
        fetchedClasses.add({
          'id': classId,
          'name': className,
          'teacher': _currentGuru!.name,
          'students': students,
        });
      }

      setState(() {
        _classesData = fetchedClasses;
      });
    } catch (e) {
      print('Error fetching classes and students: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kelas & Siswa'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _classesData.isEmpty
              ? Center(
                child: Text(
                  'Belum ada kelas yang ditugaskan kepada Anda.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _classesData.length,
                itemBuilder: (context, index) {
                  final kelas = _classesData[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: Icon(
                        Icons.class_,
                        color: AppConstants.primaryBlue[700],
                        size: 30,
                      ),
                      title: Text(
                        kelas['name'],
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: AppConstants.darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Wali Kelas: ${kelas['teacher']}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daftar Siswa (${kelas['students'].length}):',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppConstants.darkBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: kelas['students'].length,
                                itemBuilder: (context, studentIndex) {
                                  final student =
                                      kelas['students'][studentIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          student['gender'] == 'L'
                                              ? Icons.male
                                              : Icons.female,
                                          color:
                                              student['gender'] == 'L'
                                                  ? Colors.blue[700]
                                                  : Colors.pink[700],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${student['name']} (NIS: ${student['nis']})',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: AppConstants.accentBlue,
                                          ),
                                          onPressed: () {
                                            // Navigasi ke halaman laporan perkembangan dengan membawa student ID
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => OrangtuaProgressReportScreen(
                                                      studentId:
                                                          student['id'], // Kirim student ID
                                                      isTeacherView:
                                                          true, // Beri tahu bahwa ini tampilan guru
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Tambahkan siswa ke ${kelas['name']} (Fitur ini perlu implementasi lebih lanjut).',
                                        ),
                                      ),
                                    );
                                    // TODO: Implementasi tambah siswa ke kelas (melalui form)
                                  },
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Tambahkan Siswa'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.accentBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

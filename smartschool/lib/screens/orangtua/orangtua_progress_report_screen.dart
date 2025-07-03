import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_constants.dart';

// ... imports ...
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrangtuaProgressReportScreen extends StatefulWidget {
  final String? studentId; // <<<--- Tambahkan ini
  final bool isTeacherView; // <<<--- Tambahkan ini

  const OrangtuaProgressReportScreen({
    super.key,
    this.studentId,
    this.isTeacherView = false,
  }); // <<<--- Update konstruktor

  @override
  State<OrangtuaProgressReportScreen> createState() =>
      _OrangtuaProgressReportScreenState();
}

class _OrangtuaProgressReportScreenState
    extends State<OrangtuaProgressReportScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  UserModel? _currentUser; // Untuk user yang sedang login

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.isTeacherView && widget.studentId != null) {
        // Jika guru melihat laporan siswa tertentu
        _studentData = await _apiService.getStudentDetailedData(
          widget.studentId!,
        );
      } else {
        // Jika orang tua melihat laporan anaknya
        _currentUser = await _apiService.getCurrentUserData();
        if (_currentUser != null && _currentUser!.role == 'orangtua') {
          QuerySnapshot childSnapshot =
              await FirebaseFirestore.instance
                  .collection('students')
                  .where(
                    'parentId',
                    isEqualTo: _currentUser!.id,
                  ) // Tambahkan '!' untuk menyatakan bahwa _currentUser tidak null
                  .limit(1)
                  .get();

          if (childSnapshot.docs.isNotEmpty) {
            _studentData = await _apiService.getStudentDetailedData(
              childSnapshot.docs.first.id,
            );
          }
        }
      }
    } catch (e) {
      print('Error fetching student progress report: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (logika perhitungan nilai dan kehadiran, tidak berubah) ...
    double overallAverage = 0;
    if (_studentData != null &&
        _studentData!['grades'] is Map &&
        _studentData!['grades'].isNotEmpty) {
      double totalGradeSum = 0;
      int totalGradesCount = 0; // Menghitung jumlah grade yang valid
      (_studentData!['grades'] as Map<String, dynamic>).forEach((
        subject,
        grades,
      ) {
        if (grades is List && grades.isNotEmpty) {
          for (var grade in grades) {
            if (grade is num) {
              // Pastikan grade adalah angka
              totalGradeSum += grade;
              totalGradesCount++;
            }
          }
        }
      });
      overallAverage =
          totalGradesCount > 0 ? totalGradeSum / totalGradesCount : 0;
      overallAverage = double.parse(overallAverage.toStringAsFixed(2));
    }

    double attendancePercentage = 0;
    if (_studentData != null && _studentData!['attendance'] is Map) {
      int totalDays = _studentData!['attendance']['Total Hari'] ?? 0;
      int hadirDays = _studentData!['attendance']['Hadir'] ?? 0;
      attendancePercentage = totalDays > 0 ? (hadirDays / totalDays) * 100 : 0;
      attendancePercentage = double.parse(
        attendancePercentage.toStringAsFixed(2),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isTeacherView ? 'Laporan Siswa' : 'Laporan Perkembangan Anak',
        ), // Judul berbeda untuk guru
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _studentData == null || _studentData!.isEmpty
              ? Center(
                child: Text(
                  'Data perkembangan anak/siswa belum tersedia atau tidak ditemukan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Informasi Siswa'),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context,
                              'Nama Siswa:',
                              _studentData!['name'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              context,
                              'Kelas:',
                              _studentData!['class_name'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              context,
                              'Wali Kelas:',
                              _studentData!['teacher_name'] ?? 'N/A',
                            ),
                            _buildInfoRow(
                              context,
                              'Nilai Rata-rata Keseluruhan:',
                              overallAverage.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildSectionTitle(context, 'Rincian Nilai Mata Pelajaran'),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (_studentData!['grades'] as Map<String, dynamic>)
                                  .keys
                                  .map<Widget>((subject) {
                                    List<dynamic> grades =
                                        _studentData!['grades'][subject];
                                    double avgGrade =
                                        grades.isNotEmpty
                                            ? grades.cast<int>().reduce(
                                                  (a, b) => a + b,
                                                ) /
                                                grades.length
                                            : 0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$subject:',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                          ),
                                          Text(
                                            '${avgGrade.toStringAsFixed(2)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  avgGrade >= 75
                                                      ? AppConstants.darkBlue
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),

                    _buildSectionTitle(context, 'Data Kehadiran'),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context,
                              'Total Hari Sekolah:',
                              '${_studentData!['attendance']['Total Hari'] ?? 'N/A'}',
                            ),
                            _buildInfoRow(
                              context,
                              'Hari Hadir:',
                              '${_studentData!['attendance']['Hadir'] ?? 'N/A'}',
                            ),
                            _buildInfoRow(
                              context,
                              'Persentase Kehadiran:',
                              '${attendancePercentage.toString()}%',
                            ),
                            _buildInfoRow(
                              context,
                              'Sakit:',
                              '${_studentData!['attendance']['Sakit'] ?? 'N/A'}',
                            ),
                            _buildInfoRow(
                              context,
                              'Izin:',
                              '${_studentData!['attendance']['Izin'] ?? 'N/A'}',
                            ),
                            _buildInfoRow(
                              context,
                              'Alfa:',
                              '${_studentData!['attendance']['Alfa'] ?? 'N/A'}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildSectionTitle(context, 'Catatan Guru'),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (_studentData!['notes'] as List<dynamic>)
                                  .map<Widget>((note) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                            color: AppConstants.accentBlue,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              note,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),
                    if (widget
                        .isTeacherView) // Tambahkan tombol input catatan hanya untuk guru
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementasi input catatan guru untuk siswa ini
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur input catatan guru akan datang!',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                        label: const Text('Tambah Catatan Guru'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppConstants.darkBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}

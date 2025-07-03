import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart';

// ... imports ...
import 'package:smartschool/services/api_service.dart'; // Tambahkan ini
import 'package:smartschool/models/user_model.dart'; // Tambahkan ini
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini

class OrangtuaDashboardScreen extends StatefulWidget {
  // Ubah menjadi StatefulWidget
  const OrangtuaDashboardScreen({super.key});

  @override
  State<OrangtuaDashboardScreen> createState() =>
      _OrangtuaDashboardScreenState();
}

class _OrangtuaDashboardScreenState extends State<OrangtuaDashboardScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _orangtuaUser;
  Map<String, dynamic>? _childData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _orangtuaUser = await _apiService.getCurrentUserData();
      // Asumsi satu orang tua memiliki satu anak yang terdaftar di aplikasi
      // Anda mungkin perlu logika yang lebih canggih untuk banyak anak
      if (_orangtuaUser != null) {
        // Cari anak yang terhubung dengan orang tua ini
        QuerySnapshot childSnapshot =
            await FirebaseFirestore.instance
                .collection('students')
                .where('parentId', isEqualTo: _orangtuaUser!.id)
                .limit(1)
                .get();

        if (childSnapshot.docs.isNotEmpty) {
          _childData = await _apiService.getStudentDetailedData(
            childSnapshot.docs.first.id,
          );
        }
      }
    } catch (e) {
      print('Error fetching orang tua dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung rata-rata nilai dan kehadiran jika data anak tersedia
    double overallAverage = 0;
    double attendancePercentage = 0;
    if (_childData != null &&
        _childData!['grades'] is Map &&
        _childData!['grades'].isNotEmpty) {
      int totalSubjects = 0;
      double totalGradeSum = 0;
      _childData!['grades'].forEach((subject, grades) {
        if (grades is List && grades.isNotEmpty) {
          totalGradeSum += grades.reduce((a, b) => a + b);
          totalSubjects += grades.length; // Hitung setiap nilai sebagai 1
        }
      });
      overallAverage = totalSubjects > 0 ? totalGradeSum / totalSubjects : 0;
      overallAverage = double.parse(overallAverage.toStringAsFixed(2));
    }
    if (_childData != null && _childData!['attendance'] is Map) {
      int totalDays = _childData!['attendance']['Total Hari'] ?? 0;
      int hadirDays = _childData!['attendance']['Hadir'] ?? 0;
      attendancePercentage = totalDays > 0 ? (hadirDays / totalDays) * 100 : 0;
      attendancePercentage = double.parse(
        attendancePercentage.toStringAsFixed(2),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orang Tua Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthRepository().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.authRoute);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: AppConstants.primaryBlue[700]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppConstants.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _orangtuaUser?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _orangtuaUser?.email ?? 'Loading...',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // ... (ListTile lainnya, tidak berubah) ...
            ListTile(
              leading: Icon(Icons.child_care, color: AppConstants.darkBlue),
              title: const Text('Perkembangan Anak'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.orangtuaProgressReportRoute,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: AppConstants.darkBlue),
              title: const Text('Jadwal & Kegiatan Sekolah'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.siswaScheduleRoute,
                ); // Bisa melihat jadwal anak
              },
            ),
            ListTile(
              leading: Icon(
                Icons.restaurant_menu,
                color: AppConstants.darkBlue,
              ),
              title: const Text('Menu Makan Siang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.menuMakanRoute);
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: AppConstants.darkBlue),
              title: const Text('Informasi Sekolah Unggul'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.schoolInfoRoute);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: AppConstants.darkBlue),
              title: const Text('Chatbot AI'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.chatbotRoute);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                await AuthRepository().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRouter.authRoute);
                }
              },
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${_orangtuaUser?.name ?? 'Orang Tua'}!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppConstants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anak Saya: ${_childData?['name'] ?? 'Tidak ditemukan'}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppConstants.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_childData != null &&
                                _childData!.isNotEmpty) ...[
                              _buildChildInfoItem(
                                context,
                                'Kelas:',
                                _childData!['class_name'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildChildInfoItem(
                                context,
                                'Wali Kelas:',
                                _childData!['teacher_name'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildChildInfoItem(
                                context,
                                'Nilai Rata-rata:',
                                overallAverage.toString(),
                              ),
                              const Divider(),
                              _buildChildInfoItem(
                                context,
                                'Kehadiran:',
                                '$attendancePercentage%',
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.orangtuaProgressReportRoute,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.bar_chart,
                                    color: AppConstants.accentBlue,
                                  ),
                                  label: Text(
                                    'Lihat Laporan Perkembangan Lengkap',
                                    style: TextStyle(
                                      color: AppConstants.accentBlue,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppConstants.accentBlue,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              Text(
                                'Data anak belum tersedia atau tidak ditemukan.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Akses Cepat',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildQuickAccessButton(
                      context,
                      label: 'Lihat Menu Makan Siang',
                      icon: Icons.fastfood,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRouter.menuMakanRoute,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAccessButton(
                      context,
                      label: 'Kontak Guru & Admin',
                      icon: Icons.contact_mail,
                      onTap: () {
                        // TODO: Implementasi Kontak Guru & Admin
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fitur Kontak Guru & Admin akan datang!',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildChildInfoItem(BuildContext context, String label, String value) {
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

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}

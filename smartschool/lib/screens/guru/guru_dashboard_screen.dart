// File: lib/screens/guru/guru_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/services/api_service.dart'; // Tambahkan ini
import 'package:smartschool/models/user_model.dart'; // Tambahkan ini
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini jika belum ada, untuk QuerySnapshot

class GuruDashboardScreen extends StatefulWidget {
  const GuruDashboardScreen({super.key});

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _guruUser;
  Map<String, List<Map<String, String>>> _currentSchedules =
      {}; // Ubah nama variabel untuk lebih jelas
  bool _isLoading = true;
  List<Map<String, dynamic>> _allClasses = []; // <<<--- Tambahkan ini

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
      _guruUser = await _apiService.getCurrentUserData();
      _allClasses = await _apiService.getAllClasses(); // <<<--- Tambahkan ini

      // Ambil jadwal khusus guru ini
      _currentSchedules = await _apiService.getSchedule(
        teacherId: _guruUser?.id,
      );
    } catch (e) {
      print('Error fetching guru dashboard data: $e');
      // Tampilkan pesan error jika perlu
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = _getDayName(DateTime.now().weekday);
    List<Map<String, String>> todaySchedule = _currentSchedules[today] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru Dashboard'),
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
                    _guruUser?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _guruUser?.email ?? 'Loading...',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.school, color: AppConstants.darkBlue),
              title: const Text('Manajemen Sekolah Unggul'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.adminSchoolManagementRoute,
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.restaurant_menu,
                color: AppConstants.darkBlue,
              ),
              title: const Text('Manajemen Menu Makan Siang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.menuMakanRoute);
              },
            ),
            ListTile(
              leading: Icon(Icons.construction, color: AppConstants.darkBlue),
              title: const Text('Laporan Infrastruktur'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.adminInfrastructureReportsRoute,
                );
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
                      'Selamat Datang, ${_guruUser?.name ?? 'Guru'}!',
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
                              'Jadwal Mengajar Hari Ini (${_getDayName(DateTime.now().weekday)})',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppConstants.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (todaySchedule.isEmpty)
                              Text(
                                'Tidak ada jadwal mengajar hari ini.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              )
                            else
                              ...todaySchedule.map(
                                (item) => Column(
                                  children: [
                                    _buildScheduleItem(
                                      context,
                                      item['time']!,
                                      '${item['subject']} - ${item['classId'] != null ? (_allClasses.firstWhere((c) => c['id'] == item['classId'], orElse: () => {'name': 'N/A'}))['name'] : item['teacher']}',
                                    ),
                                    const Divider(),
                                  ],
                                ),
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
                      label: 'Lihat Daftar Kelas Saya',
                      icon: Icons.group,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRouter.guruClassManagementRoute,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAccessButton(
                      context,
                      label: 'Input Nilai Siswa',
                      icon: Icons.grade,
                      onTap: () {
                        /* TODO: Implementasi input nilai */
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  Widget _buildScheduleItem(
    BuildContext context,
    String time,
    String subjectClass,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppConstants.accentBlue, size: 20),
          const SizedBox(width: 10),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.darkBlue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              subjectClass,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
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

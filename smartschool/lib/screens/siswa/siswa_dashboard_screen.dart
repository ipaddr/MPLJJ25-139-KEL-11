import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/services/api_service.dart'; // Tambahkan ini
import 'package:smartschool/models/user_model.dart'; // Tambahkan ini
import 'package:smartschool/models/menu_model.dart'; // Tambahkan ini
import 'package:cloud_firestore/cloud_firestore.dart'; // <<<--- Tambahkan ini

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _siswaUser;
  MenuModel? _dailyMenu;
  Map<String, List<Map<String, String>>> _schedule = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _allClasses = []; // <<<--- Pastikan ini ada

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
      _siswaUser = await _apiService.getCurrentUserData();
      _dailyMenu = await _apiService.getDailyMenu(DateTime.now());
      _allClasses =
          await _apiService.getAllClasses(); // <<<--- Pastikan ini ada

      String? classId;
      if (_siswaUser != null) {
        QuerySnapshot studentDoc =
            await FirebaseFirestore.instance
                .collection('students')
                .where('name', isEqualTo: _siswaUser!.name)
                .limit(1)
                .get();
        if (studentDoc.docs.isNotEmpty) {
          classId = studentDoc.docs.first['classId'];
        }
      }
      _schedule = await _apiService.getSchedule(classId: classId);
    } catch (e) {
      print('Error fetching siswa dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = _getDayName(DateTime.now().weekday);
    List<Map<String, String>> todaySchedule = _schedule[today] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siswa Dashboard'),
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
                    _siswaUser?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _siswaUser?.email ?? 'Loading...',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // ... (ListTile lainnya, tidak berubah) ...
            ListTile(
              leading: Icon(Icons.schedule, color: AppConstants.darkBlue),
              title: const Text('Jadwal Pelajaran'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.siswaScheduleRoute);
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
                      'Selamat Datang, ${_siswaUser?.name ?? 'Siswa'}!',
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
                              'Jadwal Pelajaran Hari Ini (${_getDayName(DateTime.now().weekday)})',
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
                                'Tidak ada jadwal pelajaran hari ini.',
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
                                      item['subject']!,
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
                              'Menu Makan Siang Hari Ini',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppConstants.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_dailyMenu == null ||
                                _dailyMenu!.menuItems.isEmpty)
                              Text(
                                'Tidak ada menu makan siang hari ini.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              )
                            else
                              ..._dailyMenu!.menuItems.map(
                                (item) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${item.description} (${item.calories} kkal)',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 5),
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
                      label: 'Lihat Informasi Sekolah',
                      icon: Icons.info,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRouter.schoolInfoRoute,
                          ),
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

  Widget _buildScheduleItem(BuildContext context, String time, String subject) {
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
              subject,
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

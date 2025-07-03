import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart';

// ... imports ...
import 'package:smartschool/services/api_service.dart'; // Tambahkan ini
import 'package:smartschool/models/user_model.dart'; // Tambahkan ini

class AdminDashboardScreen extends StatefulWidget {
  // Ubah menjadi StatefulWidget
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _adminUser;
  int _totalGuru = 0;
  int _totalSiswa = 0;
  int _newInfrastructureReports = 0;
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
      _adminUser = await _apiService.getCurrentUserData();
      _totalGuru = (await _apiService.getAllUsersByRole('guru')).length;
      _totalSiswa = (await _apiService.getAllUsersByRole('siswa')).length;

      _apiService.getInfrastructureReports().listen((snapshot) {
        if (mounted) {
          setState(() {
            _newInfrastructureReports =
                snapshot.docs.where((doc) => doc['status'] == 'pending').length;
          });
        }
      });
    } catch (e) {
      print('Error fetching admin dashboard data: $e');
      // Tampilkan pesan error jika perlu
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
        title: const Text('Admin Dashboard'),
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
                    _adminUser?.name ?? 'Loading...', // Ambil nama dari data
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _adminUser?.email ?? 'Loading...', // Ambil email dari data
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // ... (ListTile lainnya, tidak berubah) ...
            ListTile(
              leading: Icon(Icons.school, color: AppConstants.darkBlue),
              title: const Text('Manajemen Sekolah Unggul'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
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
                Navigator.pushNamed(
                  context,
                  AppRouter.menuMakanRoute,
                ); // Dapat mengarah ke halaman yang sama dengan siswa/ortu tapi dengan tombol edit
              },
            ),
            ListTile(
              leading: Icon(
                Icons.schedule,
                color: AppConstants.darkBlue,
              ), // Atau icon lain
              title: const Text('Manajemen Jadwal Kelas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.manageSchedulesRoute,
                ); // <<<--- Tambahkan ini
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
                ); // <<<--- Ubah ini
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
                      'Ringkasan Admin',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppConstants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildDashboardCard(
                          context,
                          title: 'Sekolah',
                          value:
                              'Jumlah Sekolah', // Ini nanti bisa ambil dari ApiService().getSchools().length
                          icon: Icons.school,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                AppRouter.schoolInfoRoute,
                              ),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Guru',
                          value: '$_totalGuru', // Ambil dari Firebase
                          icon: Icons.person_outline,
                          onTap: () {
                            /* TODO: Navigasi ke daftar guru */
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Siswa',
                          value: '$_totalSiswa', // Ambil dari Firebase
                          icon: Icons.people_outline,
                          onTap: () {
                            /* TODO: Navigasi ke daftar siswa */
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Laporan Infrastruktur',
                          value:
                              '$_newInfrastructureReports Baru', // Ambil dari Firebase
                          icon: Icons.warning_amber,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                AppRouter.adminInfrastructureReportsRoute,
                              ), // <<<--- Ubah ini
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                      label: 'Kelola Sekolah Unggul',
                      icon: Icons.edit_note,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRouter.adminSchoolManagementRoute,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickAccessButton(
                      context,
                      label: 'Lihat Laporan Pemerintah',
                      icon: Icons.assessment,
                      onTap: () {
                        /* TODO: Implementasi laporan pemerintah */
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppConstants.accentBlue),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppConstants.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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

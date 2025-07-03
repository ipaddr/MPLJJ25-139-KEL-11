import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart'; // Untuk warna

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // Navigasi berdasarkan role
        switch (user.role) {
          case 'admin':
            Navigator.pushReplacementNamed(
              context,
              AppRouter.adminDashboardRoute,
            );
            break;
          case 'guru':
            Navigator.pushReplacementNamed(
              context,
              AppRouter.guruDashboardRoute,
            );
            break;
          case 'siswa':
            Navigator.pushReplacementNamed(
              context,
              AppRouter.siswaDashboardRoute,
            );
            break;
          case 'orangtua':
            Navigator.pushReplacementNamed(
              context,
              AppRouter.orangtuaDashboardRoute,
            );
            break;
          default:
            _showErrorSnackBar('Role tidak dikenal.');
            await _authRepository.signOut(); // Log out jika role tidak dikenal
        }
      } else {
        _showErrorSnackBar(
          'Login gagal: Pengguna tidak ditemukan atau kredensial salah.',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        ); // Membersihkan pesan error
      });
      _showErrorSnackBar(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login ke SmartSchool'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_smartschool.png', // Pastikan Anda memiliki logo di sini
                height: 120,
              ),
              const SizedBox(height: 32),
              Text(
                'Selamat Datang',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppConstants.primaryBlue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan masuk untuk melanjutkan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Lebar penuh
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
              const SizedBox(height: 16),
              // Tombol untuk navigasi ke RegisterScreen
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.registerRoute,
                  ); // <<<--- Tambahkan ini
                },
                child: Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(
                    color: AppConstants.primaryBlue,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tambahan: Untuk kemudahan testing, tambahkan tombol buat user dummy
              // Hapus ini di aplikasi produksi
            ],
          ),
        ),
      ),
    );
  }
}

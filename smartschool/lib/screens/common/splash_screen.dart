import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/auth/auth_repository.dart'; // Untuk mengecek status login
import 'package:smartschool/utils/app_constants.dart'; // Untuk warna

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Durasi splash screen
    if (!mounted) return;

    final currentUser = AuthRepository().getCurrentUser();
    if (currentUser != null) {
      // Jika sudah login, cek role dan arahkan ke dashboard yang sesuai
      // Perlu ambil role dari Firestore karena AuthRepository hanya berikan User ID
      final userModel = await AuthRepository().signIn(
        email: currentUser.email!,
        password: '',
      ); // Hacky way to get userModel, better to save role in local storage after first login.
      if (userModel != null) {
        String route = AppRouter.authRoute; // Default fallback
        switch (userModel.role) {
          case 'admin':
            route = AppRouter.adminDashboardRoute;
            break;
          case 'guru':
            route = AppRouter.guruDashboardRoute;
            break;
          case 'siswa':
            route = AppRouter.siswaDashboardRoute;
            break;
          case 'orangtua':
            route = AppRouter.orangtuaDashboardRoute;
            break;
        }
        Navigator.pushReplacementNamed(context, route);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.onboardingRoute);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlue[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_smartschool.png', // Ganti dengan path logo Anda
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

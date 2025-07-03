import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartschool/firebase_options.dart'; // Ini penting!

// import 'package:smartschool/screens/common/splash_screen.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart'; // Untuk tema warna

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform, // Menggunakan konfigurasi dari firebase_options.dart
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            AppConstants.primaryBlue, // Menggunakan warna biru dingin
        primaryColor: AppConstants.primaryBlue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppConstants.primaryBlue,
          accentColor: AppConstants.accentBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppConstants.accentBlue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: AppConstants.primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: AppConstants.accentBlue,
              width: 2.0,
            ),
          ),
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/', // Rute awal ke SplashScreen
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartschool/screens/common/splash_screen.dart';
import 'package:smartschool/screens/common/onboarding_screen.dart';
import 'package:smartschool/auth/auth_screen.dart';
import 'package:smartschool/auth/register_screen.dart'; // <<<--- Tambahkan ini
import 'package:smartschool/screens/admin/admin_dashboard_screen.dart';
import 'package:smartschool/screens/guru/guru_dashboard_screen.dart';
import 'package:smartschool/screens/siswa/siswa_dashboard_screen.dart';
import 'package:smartschool/screens/orangtua/orangtua_dashboard_screen.dart';
import 'package:smartschool/screens/common/chatbot_screen.dart';
import 'package:smartschool/screens/admin/admin_school_management_screen.dart';
import 'package:smartschool/screens/guru/guru_class_management_screen.dart';
import 'package:smartschool/screens/siswa/siswa_schedule_screen.dart';
import 'package:smartschool/screens/orangtua/orangtua_progress_report_screen.dart';
import 'package:smartschool/screens/common/menu_makan_screen.dart';
import 'package:smartschool/screens/common/school_info_screen.dart';
import 'package:smartschool/screens/admin/admin_infrastructure_reports_screen.dart';
import 'package:smartschool/models/menu_model.dart'; // <<<--- Tambahkan ini
import 'package:smartschool/screens/admin/manage_schedules_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String authRoute = '/auth';
  static const String registerRoute = '/register'; // <<<--- Tambahkan ini
  static const String adminDashboardRoute = '/admin_dashboard';
  static const String guruDashboardRoute = '/guru_dashboard';
  static const String siswaDashboardRoute = '/siswa_dashboard';
  static const String orangtuaDashboardRoute = '/orangtua_dashboard';
  static const String chatbotRoute = '/chatbot';
  static const String adminSchoolManagementRoute = '/admin_school_management';
  static const String guruClassManagementRoute = '/guru_class_management';
  static const String siswaScheduleRoute = '/siswa_schedule';
  static const String orangtuaProgressReportRoute = '/orangtua_progress_report';
  static const String menuMakanRoute = '/menu_makan';
  static const String schoolInfoRoute = '/school_info';
  static const String adminInfrastructureReportsRoute =
      '/admin_infrastructure_reports'; // Tambahkan ini
  static const String editMenuMakanRoute = '/edit_menu_makan';
  static const String manageSchedulesRoute =
      '/manage_schedules'; // <<<--- Tambahkan ini

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case authRoute:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case registerRoute: // <<<--- Tambahkan ini
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case adminDashboardRoute:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case guruDashboardRoute:
        return MaterialPageRoute(builder: (_) => const GuruDashboardScreen());
      case siswaDashboardRoute:
        return MaterialPageRoute(builder: (_) => const SiswaDashboardScreen());
      case orangtuaDashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const OrangtuaDashboardScreen(),
        );
      case adminInfrastructureReportsRoute: // Tambahkan ini
        return MaterialPageRoute(
          builder: (_) => const AdminInfrastructureReportsScreen(),
        );
      case chatbotRoute:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      case adminSchoolManagementRoute:
        return MaterialPageRoute(
          builder: (_) => const AdminSchoolManagementScreen(),
        );
      case guruClassManagementRoute:
        return MaterialPageRoute(
          builder: (_) => const GuruClassManagementScreen(),
        );
      case siswaScheduleRoute:
        return MaterialPageRoute(builder: (_) => const SiswaScheduleScreen());
      case orangtuaProgressReportRoute:
        return MaterialPageRoute(
          builder: (_) => const OrangtuaProgressReportScreen(),
        );
      case menuMakanRoute:
        return MaterialPageRoute(builder: (_) => const MenuMakanScreen());
      case schoolInfoRoute:
        return MaterialPageRoute(builder: (_) => const SchoolInfoScreen());
      case editMenuMakanRoute: // Tambahkan ini
        // Perlu cast arguments jika Anda menggunakan argumen non-primitif
        final args = settings.arguments as MenuModel?;
        return MaterialPageRoute(
          builder: (_) => EditMenuMakanScreen(currentMenu: args),
        );
      case manageSchedulesRoute: // <<<--- Tambahkan ini
        return MaterialPageRoute(builder: (_) => const ManageSchedulesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Text('Error: Unknown route'),
        );
    }
  }
}

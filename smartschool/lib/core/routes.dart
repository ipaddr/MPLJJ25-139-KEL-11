import 'package:flutter/material.dart';

// Auth
import '../screen/auth/login_screen.dart';
import '../screen/auth/forgot_password_screen.dart';
import '../screen/auth/register_screen.dart';

// Dashboard & Bottom Navigation
import '../screen/dashboard/dashboard_screen.dart';
import '../screen/common/bottom_nav.dart';

// Assignment
import '../screen/assignment/assignment_list_screen.dart';
import '../screen/assignment/create_assignment_screen.dart';

// Test
import '../screen/test/test_list_screen.dart';
import '../screen/test/create_test_screen.dart';

// Attendance & Report
import '../screen/attendance/attendance_screen.dart';
import '../screen/attendance/report_issue_screen.dart';

// Timetable & Meal
import '../screen/timetable/timetable_screen.dart';
import '../screen/meal/meal_plan_screen.dart';

// Chat
import '../screen/chat/chat_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String dashboard = '/dashboard';
  static const String bottomNav = '/home';

  static const String assignments = '/assignments';
  static const String createAssignment = '/assignments/create';

  static const String tests = '/tests';
  static const String createTest = '/tests/create';

  static const String attendance = '/attendance';
  static const String reportIssue = '/report-issue';

  static const String timetable = '/timetable';
  static const String mealPlan = '/meal-plan';

  static const String chat = '/chat';

  static final routes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),

    dashboard: (_) => const DashboardScreen(),
    bottomNav: (_) => const BottomNav(),

    assignments: (_) => const AssignmentListScreen(),
    createAssignment: (_) => const CreateAssignmentScreen(),

    tests: (_) => const TestListScreen(),
    createTest: (_) => const CreateTestScreen(),

    attendance: (_) => const AttendanceScreen(),
    reportIssue: (_) => const ReportIssueScreen(),

    timetable: (_) => const TimetableScreen(),
    mealPlan: (_) => const MealPlanScreen(),

    chat: (_) => const ChatScreen(),
  };
}

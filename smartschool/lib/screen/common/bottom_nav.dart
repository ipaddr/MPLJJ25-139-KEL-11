import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../assignment/assignment_list_screen.dart';
import '../test/test_list_screen.dart';
import '../attendance/attendance_screen.dart';
import '../chat/chat_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  // List halaman yang akan diakses via bottom nav
  final List<Widget> _pages = const [
    DashboardScreen(),
    AssignmentListScreen(),
    TestListScreen(),
    AttendanceScreen(),
    ChatScreen(chatRoomId: 'general', chatPartnerName: 'Group Chat'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Tests'),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartschool/models/school_model.dart';
import 'package:smartschool/models/menu_model.dart';
import 'package:smartschool/models/user_model.dart'; // Import UserModel
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan UID user yang sedang login

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Tambahkan ini

  // --- User Related (Untuk mendapatkan detail user yang sedang login) ---
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromDocumentSnapshot(userDoc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  Future<List<UserModel>> getAllUsersByRole(String role) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: role)
              .get();
      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting users by role $role: $e');
      return [];
    }
  }

  // --- School Related ---
  Future<List<SchoolModel>> getSchools() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('schools').get();
      return snapshot.docs
          .map((doc) => SchoolModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting schools: $e');
      return [];
    }
  }

  Future<void> addSchool(SchoolModel school) async {
    try {
      await _firestore.collection('schools').add(school.toMap());
    } catch (e) {
      print('Error adding school: $e');
      rethrow;
    }
  }

  Future<void> updateSchool(SchoolModel school) async {
    // <<<--- Tambahkan ini
    try {
      await _firestore
          .collection('schools')
          .doc(school.id)
          .update(school.toMap());
    } catch (e) {
      print('Error updating school: $e');
      rethrow;
    }
  }

  Future<void> deleteSchool(String schoolId) async {
    // <<<--- Tambahkan ini
    try {
      await _firestore.collection('schools').doc(schoolId).delete();
    } catch (e) {
      print('Error deleting school: $e');
      rethrow;
    }
  }

  // --- Menu Related ---
  Future<MenuModel?> getDailyMenu(DateTime date) async {
    try {
      // Untuk kesederhanaan, asumsikan ID dokumen adalah tanggal dalam format YYYY-MM-DD
      String docId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      DocumentSnapshot doc =
          await _firestore.collection('daily_menus').doc(docId).get();
      if (doc.exists) {
        return MenuModel.fromDocumentSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error getting daily menu: $e');
      return null;
    }
  }

  Future<void> setDailyMenu(MenuModel menu) async {
    try {
      String docId =
          '${menu.date.year}-${menu.date.month.toString().padLeft(2, '0')}-${menu.date.day.toString().padLeft(2, '0')}';
      await _firestore.collection('daily_menus').doc(docId).set(menu.toMap());
    } catch (e) {
      print('Error setting daily menu: $e');
      rethrow;
    }
  }

  // --- Infrastructure Related (contoh sederhana) ---
  Future<void> reportInfrastructureIssue({
    required String schoolId,
    required String facilityName,
    required String issueDescription,
    required String reportedByUserId,
  }) async {
    try {
      await _firestore.collection('infrastructure_reports').add({
        'schoolId': schoolId,
        'facilityName': facilityName,
        'issueDescription': issueDescription,
        'reportedBy': reportedByUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // 'pending', 'in_progress', 'completed'
      });
    } catch (e) {
      print('Error reporting infrastructure issue: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getInfrastructureReports() {
    return _firestore.collection('infrastructure_reports').snapshots();
  }

  // --- New: Get student data and grades for parents/teachers ---
  // Ini memerlukan Anda memiliki koleksi 'students' dan 'grades' di Firestore
  // Contoh struktur Firestore:
  // /students/{studentId} -> { name: "Ali Siswa", classId: "kelas7A", parentId: "ortuUid" }
  // /grades/{gradeId} -> { studentId: "studentId", subject: "Matematika", value: 90, date: timestamp }
  // /attendance/{attendanceId} -> { studentId: "studentId", date: timestamp, status: "Hadir" }

  Future<Map<String, dynamic>> getStudentDetailedData(String studentId) async {
    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) return {};

      Map<String, dynamic> studentData =
          studentDoc.data() as Map<String, dynamic>;

      // Fetch grades
      QuerySnapshot gradesSnapshot =
          await _firestore
              .collection('grades')
              .where('studentId', isEqualTo: studentId)
              .get();
      Map<String, List<int>> grades = {};
      for (var doc in gradesSnapshot.docs) {
        String subject = doc['subject'];
        int value = doc['value'];
        grades.putIfAbsent(subject, () => []).add(value);
      }
      studentData['grades'] = grades;

      // Fetch attendance (simplified for total hadir/alpha/izin)
      QuerySnapshot attendanceSnapshot =
          await _firestore
              .collection('attendance')
              .where('studentId', isEqualTo: studentId)
              .get();
      int totalDays = attendanceSnapshot.docs.length;
      int hadir =
          attendanceSnapshot.docs
              .where((doc) => doc['status'] == 'Hadir')
              .length;
      int sakit =
          attendanceSnapshot.docs
              .where((doc) => doc['status'] == 'Sakit')
              .length;
      int izin =
          attendanceSnapshot.docs
              .where((doc) => doc['status'] == 'Izin')
              .length;
      int alpha = totalDays - hadir - sakit - izin; // Asumsi sisanya alpha
      studentData['attendance'] = {
        'Total Hari': totalDays,
        'Hadir': hadir,
        'Sakit': sakit,
        'Izin': izin,
        'Alfa': alpha,
      };

      // Fetch notes (simplified)
      QuerySnapshot notesSnapshot =
          await _firestore
              .collection('notes')
              .where('studentId', isEqualTo: studentId)
              .get();
      List<String> notes =
          notesSnapshot.docs.map((doc) => doc['text'] as String).toList();
      studentData['notes'] = notes;

      // Fetch class info
      if (studentData['classId'] != null) {
        DocumentSnapshot classDoc =
            await _firestore
                .collection('classes')
                .doc(studentData['classId'])
                .get();
        if (classDoc.exists) {
          studentData['class_name'] = classDoc['name'];
          studentData['teacher_id'] = classDoc['teacherId'];
          if (studentData['teacher_id'] != null) {
            DocumentSnapshot teacherDoc =
                await _firestore
                    .collection('users')
                    .doc(studentData['teacher_id'])
                    .get();
            if (teacherDoc.exists) {
              studentData['teacher_name'] = teacherDoc['name'];
            }
          }
        }
      }

      return studentData;
    } catch (e) {
      print('Error getting student detailed data: $e');
      return {};
    }
  }

  // New: Get class schedule for student/teacher
  // Contoh struktur Firestore:
  Future<Map<String, List<Map<String, String>>>> getSchedule({
    String? classId,
    String? teacherId,
  }) async {
    Map<String, List<Map<String, String>>> schedule = {
      'Senin': [], 'Selasa': [], 'Rabu': [], 'Kamis': [], 'Jumat': [],
      'Sabtu': [], 'Minggu': [], // Tambahkan hari weekend jika jadwal ada
    };
    try {
      Query query = _firestore.collection('schedules');
      if (classId != null && classId.isNotEmpty) {
        query = query.where('classId', isEqualTo: classId);
      } else if (teacherId != null && teacherId.isNotEmpty) {
        // Asumsi ada field teacherId atau yang serupa di dokumen jadwal
        query = query.where('teacherId', isEqualTo: teacherId);
      }
      QuerySnapshot snapshot = await query.get();
      for (var doc in snapshot.docs) {
        String day = doc['day'];
        Map<String, String> lesson = {
          'id': doc.id, // Tambahkan ID dokumen agar bisa diedit/dihapus
          'time': doc['time'],
          'subject': doc['subject'],
          'teacher': doc['teacherName'] ?? '',
          'classId': doc['classId'] ?? '', // Tambahkan classId
          'teacherId': doc['teacherId'] ?? '', // Tambahkan teacherId
        };
        if (schedule.containsKey(day)) {
          schedule[day]!.add(lesson);
        }
      }
      // Urutkan jadwal berdasarkan waktu
      schedule.forEach((key, value) {
        value.sort(
          (a, b) => _parseTime(a['time']!).compareTo(_parseTime(b['time']!)),
        );
      });
    } catch (e) {
      print('Error getting schedule: $e');
    }
    return schedule;
  }

  // Helper untuk parsing waktu
  DateTime _parseTime(String time) {
    try {
      // Asumsi format "HH:MM - HH:MM"
      String startTime = time.split(' - ')[0];
      final parts = startTime.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return DateTime(0); // Return minimal datetime jika parsing gagal
    }
  }

  Future<void> addSchedule({
    required String classId,
    required String day,
    required String time,
    required String subject,
    required String teacherName,
    required String teacherId, // Tambahkan teacherId
  }) async {
    try {
      await _firestore.collection('schedules').add({
        'classId': classId,
        'day': day,
        'time': time,
        'subject': subject,
        'teacherName': teacherName,
        'teacherId': teacherId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding schedule: $e');
      rethrow;
    }
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String classId,
    required String day,
    required String time,
    required String subject,
    required String teacherName,
    required String teacherId, // Tambahkan teacherId
  }) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).update({
        'classId': classId,
        'day': day,
        'time': time,
        'subject': subject,
        'teacherName': teacherName,
        'teacherId': teacherId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).delete();
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }

  // --- New: Get all classes (for dropdown in schedule management) ---
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('classes').get();
      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc['name'],
              'teacherId':
                  doc['teacherId'], // Pastikan field ini ada di Firestore
            },
          )
          .toList();
    } catch (e) {
      print('Error getting all classes: $e');
      return [];
    }
  }

  // New: Get all teachers (for dropdown in schedule management)
  Future<List<UserModel>> getAllTeachers() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'guru')
              .get();
      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting all teachers: $e');
      return [];
    }
  }

  // New: Get students in a specific class
  Future<List<Map<String, dynamic>>> getStudentsInClass(String classId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('students')
              .where('classId', isEqualTo: classId)
              .get();
      return snapshot.docs
          .map(
            (doc) => {
              'name': doc['name'],
              'nis': doc['nis'],
              'gender': doc['gender'],
              'id': doc.id,
            },
          )
          .toList();
    } catch (e) {
      print('Error getting students in class: $e');
      return [];
    }
  }
}

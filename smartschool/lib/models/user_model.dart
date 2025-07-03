import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'guru', 'siswa', 'orangtua'

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'siswa', // Default role jika tidak ada
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'role': role};
  }
}

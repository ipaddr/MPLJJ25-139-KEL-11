class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // contoh: 'admin', 'teacher', 'staff'
  final String profileImageUrl;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profileImageUrl,
    this.phoneNumber,
  });

  /// Membuat user dari Map (misalnya dari Firebase atau REST API)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'staff',
      profileImageUrl: map['profileImageUrl'] ?? '',
      phoneNumber: map['phoneNumber'],
    );
  }

  /// Konversi ke Map (untuk simpan ke Firestore atau kirim via API)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
    };
  }
}

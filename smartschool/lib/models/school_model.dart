import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id;
  final String name;
  final String address;
  final String description;
  final List<String> facilities; // Daftar fasilitas

  SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    this.facilities = const [],
  });

  factory SchoolModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SchoolModel(
      id: doc.id,
      name: data['name'] ?? 'Nama Sekolah',
      address: data['address'] ?? 'Alamat Tidak Diketahui',
      description: data['description'] ?? 'Deskripsi belum tersedia.',
      facilities: List<String>.from(data['facilities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'description': description,
      'facilities': facilities,
    };
  }
}

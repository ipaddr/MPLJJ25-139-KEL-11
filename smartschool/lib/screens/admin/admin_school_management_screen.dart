import 'package:flutter/material.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/school_model.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/screens/widgets/custom_text_field.dart'; // Tambahkan ini

class AdminSchoolManagementScreen extends StatefulWidget {
  const AdminSchoolManagementScreen({super.key});

  @override
  State<AdminSchoolManagementScreen> createState() =>
      _AdminSchoolManagementScreenState();
}

class _AdminSchoolManagementScreenState
    extends State<AdminSchoolManagementScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>(); // <<<--- Tambahkan ini
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();

  List<SchoolModel> _schools = [];
  bool _isLoading = true;
  String? _errorMessage;
  SchoolModel? _editingSchool; // Untuk menyimpan sekolah yang sedang diedit

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _schools = await _apiService.getSchools();
      if (_schools.isEmpty) {
        _errorMessage = "Belum ada sekolah yang terdaftar.";
      }
    } catch (e) {
      _errorMessage = "Gagal mengambil data sekolah: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSchool() async {
    if (_formKey.currentState!.validate()) {
      // <<<--- Validasi form
      setState(() {
        _isLoading = true;
      });

      List<String> facilities =
          _facilitiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      SchoolModel schoolToSave;
      if (_editingSchool == null) {
        // Tambah sekolah baru
        schoolToSave = SchoolModel(
          id: '', // Firestore akan mengisi ID
          name: _nameController.text,
          address: _addressController.text,
          description:
              _descriptionController.text.isEmpty
                  ? 'Deskripsi belum tersedia.'
                  : _descriptionController.text,
          facilities: facilities,
        );
        await _apiService.addSchool(schoolToSave);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sekolah berhasil ditambahkan!')),
          );
        }
      } else {
        // Update sekolah yang sudah ada
        schoolToSave = SchoolModel(
          id: _editingSchool!.id,
          name: _nameController.text,
          address: _addressController.text,
          description:
              _descriptionController.text.isEmpty
                  ? 'Deskripsi belum tersedia.'
                  : _descriptionController.text,
          facilities: facilities,
        );
        await _apiService.updateSchool(
          schoolToSave,
        ); // Perlu metode updateSchool di ApiService
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sekolah berhasil diperbarui!')),
          );
        }
      }

      _clearForm();
      await _fetchSchools(); // Refresh daftar sekolah
    }
  }

  void _editSchool(SchoolModel school) {
    setState(() {
      _editingSchool = school;
      _nameController.text = school.name;
      _addressController.text = school.address;
      _descriptionController.text = school.description;
      _facilitiesController.text = school.facilities.join(', ');
    });
  }

  Future<void> _deleteSchool(String schoolId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Anda yakin ingin menghapus sekolah ini secara permanen?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _apiService.deleteSchool(
          schoolId,
        ); // Perlu metode deleteSchool di ApiService
        await _fetchSchools();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sekolah berhasil dihapus!')),
          );
        }
      } catch (e) {
        print('Error deleting school: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus sekolah: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      _editingSchool = null;
      _nameController.clear();
      _addressController.clear();
      _descriptionController.clear();
      _facilitiesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Sekolah Unggul'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingSchool == null ? 'Tambah Sekolah Baru' : 'Edit Sekolah',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppConstants.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              // <<<--- Bungkus dengan Form
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Nama Sekolah',
                    hintText: 'Misal: SD Unggul Harapan Bangsa',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama sekolah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Alamat Sekolah',
                    hintText: 'Misal: Jl. Pendidikan No. 10',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat sekolah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    labelText: 'Deskripsi Sekolah',
                    hintText: 'Deskripsi singkat tentang sekolah...',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _facilitiesController,
                    labelText: 'Fasilitas (pisahkan dengan koma)',
                    hintText:
                        'Misal: Laboratorium, Perpustakaan, Lapangan Olahraga',
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveSchool,
                              icon: Icon(
                                _editingSchool == null
                                    ? Icons.add_business
                                    : Icons.save,
                              ),
                              label: Text(
                                _editingSchool == null
                                    ? 'Tambah Sekolah'
                                    : 'Simpan Perubahan',
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ),
                          if (_editingSchool != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearForm,
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.grey,
                                ),
                                label: const Text(
                                  'Batal Edit',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),
            Text(
              'Daftar Sekolah Terdaftar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppConstants.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading && _schools.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                    ),
                  ),
                )
                : _schools.isEmpty
                ? Center(
                  child: Text(
                    'Belum ada sekolah yang ditambahkan.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _schools.length,
                  itemBuilder: (context, index) {
                    final school = _schools[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          school.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppConstants.darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          school.address,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: AppConstants.accentBlue,
                              ),
                              onPressed:
                                  () =>
                                      _editSchool(school), // <<<--- Tambah edit
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _deleteSchool(
                                    school.id,
                                  ), // <<<--- Tambah delete
                            ),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Detail ${school.name}')),
                          );
                        },
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

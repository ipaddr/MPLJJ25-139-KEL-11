import 'package:flutter/material.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/user_model.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/screens/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  String? _selectedDay;
  String? _selectedClassId;
  String? _selectedTeacherId; // ID guru yang dipilih

  List<Map<String, dynamic>> _allClasses = [];
  List<UserModel> _allTeachers = [];

  Map<String, List<Map<String, String>>> _currentSchedules = {};
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, String>?
  _editingSchedule; // Untuk menyimpan jadwal yang sedang diedit

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _allClasses = await _apiService.getAllClasses();
      _allTeachers = await _apiService.getAllTeachers();
      await _fetchAllSchedules();
    } catch (e) {
      _errorMessage = "Gagal memuat data awal: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllSchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentSchedules = await _apiService.getSchedule(
        classId: null,
        teacherId: null,
      ); // Ambil semua jadwal
    } catch (e) {
      _errorMessage = "Gagal memuat jadwal: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Dapatkan nama guru dari ID yang dipilih
        String teacherName =
            _allTeachers
                .firstWhere((teacher) => teacher.id == _selectedTeacherId)
                .name;

        if (_editingSchedule == null) {
          await _apiService.addSchedule(
            classId: _selectedClassId!,
            day: _selectedDay!,
            time: _timeController.text,
            subject: _subjectController.text,
            teacherName: teacherName,
            teacherId: _selectedTeacherId!,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
            );
          }
        } else {
          await _apiService.updateSchedule(
            scheduleId: _editingSchedule!['id']!,
            classId: _selectedClassId!,
            day: _selectedDay!,
            time: _timeController.text,
            subject: _subjectController.text,
            teacherName: teacherName,
            teacherId: _selectedTeacherId!,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jadwal berhasil diperbarui!')),
            );
          }
        }
        _clearForm();
        await _fetchAllSchedules(); // Refresh jadwal
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editSchedule(Map<String, String> schedule) {
    setState(() {
      _editingSchedule = schedule;
      _selectedDay = schedule['day'];
      _selectedClassId = schedule['classId'];
      _timeController.text = schedule['time']!;
      _subjectController.text = schedule['subject']!;
      _selectedTeacherId = schedule['teacherId'];
    });
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Anda yakin ingin menghapus jadwal ini?'),
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
        await _apiService.deleteSchedule(scheduleId);
        await _fetchAllSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus!')),
          );
        }
      } catch (e) {
        print('Error deleting schedule: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus jadwal: $e')));
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
      _editingSchedule = null;
      _selectedDay = null;
      _selectedClassId = null;
      _selectedTeacherId = null;
      _timeController.clear();
      _subjectController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal Kelas'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingSchedule == null
                          ? 'Tambah Jadwal Baru'
                          : 'Edit Jadwal',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Hari',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: AppConstants.primaryBlue[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            value: _selectedDay,
                            hint: const Text('Pilih Hari'),
                            items:
                                _days.map((String day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(day),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDay = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hari tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Kelas',
                              prefixIcon: Icon(
                                Icons.class_,
                                color: AppConstants.primaryBlue[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            value: _selectedClassId,
                            hint: const Text('Pilih Kelas'),
                            items:
                                _allClasses.map((cl) {
                                  return DropdownMenuItem<String>(
                                    value: cl['id'],
                                    child: Text(cl['name']),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedClassId = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kelas tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _timeController,
                            labelText: 'Waktu (HH:MM - HH:MM)',
                            hintText: 'Misal: 08:00 - 09:00',
                            prefixIcon: Icons.access_time,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu tidak boleh kosong';
                              }
                              if (!RegExp(
                                r'^\d{2}:\d{2} - \d{2}:\d{2}$',
                              ).hasMatch(value)) {
                                return 'Format waktu harus HH:MM - HH:MM';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _subjectController,
                            labelText: 'Mata Pelajaran',
                            hintText: 'Misal: Matematika',
                            prefixIcon: Icons.book,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mata pelajaran tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Pengajar',
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppConstants.primaryBlue[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            value: _selectedTeacherId,
                            hint: const Text('Pilih Pengajar'),
                            items:
                                _allTeachers.map((teacher) {
                                  return DropdownMenuItem<String>(
                                    value: teacher.id,
                                    child: Text(teacher.name),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTeacherId = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pengajar tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addOrUpdateSchedule,
                                  icon: Icon(
                                    _editingSchedule == null
                                        ? Icons.add
                                        : Icons.save,
                                  ),
                                  label: Text(
                                    _editingSchedule == null
                                        ? 'Tambah Jadwal'
                                        : 'Simpan Perubahan',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                ),
                              ),
                              if (_editingSchedule != null) ...[
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
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
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
                      'Daftar Jadwal',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _currentSchedules.isEmpty &&
                            !_isLoading // Tampilkan pesan jika tidak ada jadwal dan bukan loading
                        ? Center(
                          child: Text(
                            'Tidak ada jadwal terdaftar.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        )
                        : Column(
                          children:
                              _days.map((day) {
                                List<Map<String, String>> dailyLessons =
                                    _currentSchedules[day] ?? [];
                                if (dailyLessons.isEmpty) {
                                  return const SizedBox.shrink(); // Jangan tampilkan jika tidak ada jadwal di hari itu
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        day,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.darkBlue,
                                        ),
                                      ),
                                      children:
                                          dailyLessons.map((lesson) {
                                            return ListTile(
                                              title: Text(
                                                '${lesson['time']} - ${lesson['subject']}',
                                              ),
                                              subtitle: Text(
                                                'Kelas: ${_allClasses.firstWhere((cl) => cl['id'] == lesson['classId'])['name'] ?? 'N/A'} - Pengajar: ${lesson['teacher']}',
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color:
                                                          AppConstants
                                                              .accentBlue,
                                                    ),
                                                    onPressed:
                                                        () => _editSchedule(
                                                          lesson,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed:
                                                        () => _deleteSchedule(
                                                          lesson['id']!,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
    );
  }
}

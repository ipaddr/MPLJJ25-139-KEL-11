import 'package:flutter/material.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/school_model.dart';
import 'package:smartschool/utils/app_constants.dart';

class SchoolInfoScreen extends StatefulWidget {
  const SchoolInfoScreen({super.key});

  @override
  State<SchoolInfoScreen> createState() => _SchoolInfoScreenState();
}

class _SchoolInfoScreenState extends State<SchoolInfoScreen> {
  final ApiService _apiService = ApiService();
  List<SchoolModel> _schools = [];
  bool _isLoading = true;
  String? _errorMessage;

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
        _errorMessage = "Tidak ada data sekolah unggulan yang tersedia.";
      }
    } catch (e) {
      _errorMessage = "Gagal mengambil data sekolah: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Sekolah Unggul'),
        centerTitle: true,
      ),
      body:
          _isLoading
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
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _schools.length,
                itemBuilder: (context, index) {
                  final school = _schools[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            school.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppConstants.darkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            school.address,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            school.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          if (school.facilities.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fasilitas:',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children:
                                      school.facilities
                                          .map(
                                            (f) => Chip(
                                              label: Text(f),
                                              backgroundColor: AppConstants
                                                  .lightBlue
                                                  .withOpacity(0.5),
                                              labelStyle: TextStyle(
                                                color: AppConstants.darkBlue,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton.icon(
                              onPressed: () {
                                // Contoh: navigasi ke detail sekolah
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Detail ${school.name}'),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.info_outline,
                                color: AppConstants.accentBlue,
                              ),
                              label: Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: AppConstants.accentBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

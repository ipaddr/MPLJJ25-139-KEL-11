import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/utils/app_constants.dart';

class AdminInfrastructureReportsScreen extends StatefulWidget {
  const AdminInfrastructureReportsScreen({super.key});

  @override
  State<AdminInfrastructureReportsScreen> createState() =>
      _AdminInfrastructureReportsScreenState();
}

class _AdminInfrastructureReportsScreenState
    extends State<AdminInfrastructureReportsScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Infrastruktur'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _apiService.getInfrastructureReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada laporan infrastruktur saat ini.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;
              final timestamp = (report['timestamp'] as Timestamp?)?.toDate();
              final status = report['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  title: Text(
                    report['facilityName'] ?? 'Fasilitas Tidak Diketahui',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.darkBlue,
                    ),
                  ),
                  subtitle: Text(
                    'Sekolah: ${report['schoolId'] ?? 'N/A'} - Status: ${status.toUpperCase()}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi Masalah:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            report['issueDescription'] ??
                                'Tidak ada deskripsi.',
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Dilaporkan Oleh ID:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(report['reportedBy'] ?? 'Tidak Diketahui'),
                          const SizedBox(height: 10),
                          Text(
                            'Tanggal Laporan:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            timestamp != null
                                ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                                : 'N/A',
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Ubah Status',
                              border: OutlineInputBorder(),
                            ),
                            value: status,
                            items:
                                [
                                      'pending',
                                      'in_progress',
                                      'completed',
                                      'rejected',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (String? newStatus) async {
                              if (newStatus != null) {
                                await _updateReportStatus(reportId, newStatus);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  () => _showDeleteConfirmation(reportId),
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Hapus Laporan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.info_outline;
      case 'in_progress':
        return Icons.engineering;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return AppConstants.accentBlue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('infrastructure_reports')
          .doc(reportId)
          .update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status laporan berhasil diperbarui menjadi ${newStatus.toUpperCase()}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error updating report status: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
      }
    }
  }

  Future<void> _showDeleteConfirmation(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Anda yakin ingin menghapus laporan ini secara permanen?',
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
      await _deleteReport(reportId);
    }
  }

  Future<void> _deleteReport(String reportId) async {
    try {
      await FirebaseFirestore.instance
          .collection('infrastructure_reports')
          .doc(reportId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dihapus.')),
        );
      }
    } catch (e) {
      print('Error deleting report: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus laporan: $e')));
      }
    }
  }
}

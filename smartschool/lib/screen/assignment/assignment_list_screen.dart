import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignment_model.dart';
import '../../providers/assignment_provider.dart';
import '../../core/routes.dart';
import '../../widgets/assignment_card.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  @override
  void initState() {
    super.initState();
    // Load assignments saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssignmentProvider>(
        context,
        listen: false,
      ).fetchAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createAssignment);
            },
          ),
        ],
      ),
      body:
          assignmentProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : assignmentProvider.assignments.isEmpty
              ? const Center(child: Text('No assignments found'))
              : ListView.builder(
                itemCount: assignmentProvider.assignments.length,
                itemBuilder: (context, index) {
                  AssignmentModel assignment =
                      assignmentProvider.assignments[index];
                  return AssignmentCard(
                    assignment: assignment,
                    onDelete: () async {
                      await assignmentProvider.deleteAssignment(assignment.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assignment deleted')),
                      );
                    },
                    onTap: () {
                      // Bisa tambah detail atau edit nanti
                    },
                  );
                },
              ),
    );
  }
}

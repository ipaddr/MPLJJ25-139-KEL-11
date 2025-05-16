import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignment_model.dart';
import '../../providers/assignment_provider.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classSectionController = TextEditingController();
  DateTime? _dueDate;
  String? _attachmentUrl; // Bisa dikembangkan untuk upload file

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a description'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a subject'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classSectionController,
                decoration: const InputDecoration(labelText: 'Class Section'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter a class section'
                            : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    final newAssignment = AssignmentModel(
                      id:
                          DateTime.now().millisecondsSinceEpoch
                              .toString(), // buat id unik sederhana
                      title: _titleController.text,
                      description: _descriptionController.text,
                      subject: _subjectController.text,
                      classSection: _classSectionController.text,
                      dueDate: _dueDate!,
                      attachmentUrl: _attachmentUrl ?? '',
                    );

                    await assignmentProvider.addAssignment(newAssignment);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assignment created successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } else if (_dueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a due date')),
                    );
                  }
                },
                child:
                    assignmentProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _dueDate = selected;
      });
    }
  }
}

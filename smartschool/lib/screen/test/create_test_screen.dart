import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/test_model.dart';
import '../../providers/test_provider.dart';

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classSectionController = TextEditingController();
  final TextEditingController _maximumMarksController = TextEditingController();
  final TextEditingController _minimumMarksController = TextEditingController();

  DateTime? _testDate;
  String? _gradingType;
  final List<String> _gradingTypes = ['Marks', 'Grade', 'Pass/Fail'];

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Test Title'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter test title'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter subject'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classSectionController,
                decoration: const InputDecoration(labelText: 'Class Section'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter class section'
                            : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _testDate == null
                      ? 'Select Test Date'
                      : 'Test Date: ${_testDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickTestDate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Grading Type'),
                items:
                    _gradingTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                value: _gradingType,
                onChanged: (val) => setState(() => _gradingType = val),
                validator:
                    (val) => val == null ? 'Please select grading type' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maximumMarksController,
                decoration: const InputDecoration(labelText: 'Maximum Marks'),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter maximum marks'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minimumMarksController,
                decoration: const InputDecoration(labelText: 'Minimum Marks'),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Please enter minimum marks'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _testDate != null) {
                    final newTest = TestModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text.trim(),
                      subject: _subjectController.text.trim(),
                      classSection: _classSectionController.text.trim(),
                      testDate: _testDate!,
                      gradingType: _gradingType!,
                      maximumMarks: int.tryParse(
                        _maximumMarksController.text.trim(),
                      ),
                      minimumMarks: int.tryParse(
                        _minimumMarksController.text.trim(),
                      ),
                    );

                    await testProvider.addTest(newTest);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test created successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } else if (_testDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select test date')),
                    );
                  }
                },
                child:
                    testProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTestDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _testDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _testDate = selected;
      });
    }
  }
}

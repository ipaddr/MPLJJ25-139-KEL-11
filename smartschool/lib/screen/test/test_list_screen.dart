import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/test_model.dart';
import '../../providers/test_provider.dart';
import '../../core/routes.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TestProvider>(context, listen: false).fetchTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createTest);
            },
          ),
        ],
      ),
      body:
          testProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : testProvider.tests.isEmpty
              ? const Center(child: Text('No tests found'))
              : ListView.builder(
                itemCount: testProvider.tests.length,
                itemBuilder: (context, index) {
                  TestModel test = testProvider.tests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(test.title),
                      subtitle: Text(
                        'Subject: ${test.subject}\nDate: ${test.testDate.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await testProvider.deleteTest(test.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test deleted')),
                          );
                        },
                      ),
                      onTap: () {
                        // Bisa tambah navigasi ke detail test/edit
                      },
                    ),
                  );
                },
              ),
    );
  }
}

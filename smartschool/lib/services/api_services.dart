import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/assignment_model.dart';
import '../models/test_model.dart';
import '../models/user_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // ----------------------- User Authentication ------------------------

  Future<UserModel?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    final response = await http.post(
      url,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromMap(data['user'], data['user']['id']);
    } else {
      throw Exception('Failed to login');

      ///
    }
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/api/register');
    final response = await http.post(
      url,
      body: json.encode(userData),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 201;
  }

  // ----------------------- Assignment ------------------------

  Future<List<AssignmentModel>> getAssignments() async {
    final url = Uri.parse('$baseUrl/api/assignments');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => AssignmentModel.fromMap(item, item['id']))
          .toList();
    } else {
      throw Exception('Failed to load assignments');
    }
  }

  Future<bool> addAssignment(AssignmentModel assignment) async {
    final url = Uri.parse('$baseUrl/api/assignments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(assignment.toMap()),
    );

    return response.statusCode == 201;
  }

  Future<bool> deleteAssignment(String id) async {
    final url = Uri.parse('$baseUrl/api/assignments/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  // ----------------------- Test ------------------------

  Future<List<TestModel>> getTests() async {
    final url = Uri.parse('$baseUrl/api/tests');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TestModel.fromMap(item, item['id'])).toList();
    } else {
      throw Exception('Failed to load tests');
    }
  }

  Future<bool> addTest(TestModel test) async {
    final url = Uri.parse('$baseUrl/api/tests');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(test.toMap()),
    );

    return response.statusCode == 201;
  }

  Future<bool> deleteTest(String id) async {
    final url = Uri.parse('$baseUrl/api/tests/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  // ----------------------- Additional methods like chat, attendance etc. can be added similarly ------------------------
}

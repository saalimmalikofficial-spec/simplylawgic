// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simplylawgic/services/storage_service.dart'; // Add this import
import '../models/student_model.dart';
import '../models/subject_notes.dart';
import '../models/test_series.dart';

class ApiService {
  static const String baseUrl = 'https://simply-lawgic-75585420080.asia-south1.run.app/api';
  final StorageService _storage = StorageService();

  // Existing sign in method
  Future<SignInResponse> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/student/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SignInResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Sign in failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Send OTP method
  Future<Map<String, dynamic>> sendOTP(String phone) async {
    final url = Uri.parse('$baseUrl/student/auth/phone/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify OTP method
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
    final url = Uri.parse('$baseUrl/student/auth/phone/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phone,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Add signup method
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> signupData) async {
    final url = Uri.parse('$baseUrl/student/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(signupData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get subject-wise notes
  Future<List<SubjectNotes>> getSubjectNotes() async {
    final url = Uri.parse('$baseUrl/subject-wise-notes/public');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return SubjectNotes.fromJsonList(data);
      } else {
        throw Exception('Failed to load subject notes');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get single subject note by slug
  Future<SubjectNotes> getSubjectNoteBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/subject-wise-notes/public/$slug');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SubjectNotes.fromJson(data);
      } else {
        throw Exception('Failed to load note details');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get test series
  Future<List<TestSeries>> getTestSeries() async {
    final url = Uri.parse('$baseUrl/test-series/public');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return TestSeries.fromJsonList(data);
      } else {
        throw Exception('Failed to load test series');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get single test series by slug
  Future<TestSeries> getTestSeriesBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/test-series/public/$slug');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TestSeries.fromJson(data);
      } else {
        throw Exception('Failed to load test series details');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Start test attempt
// lib/services/api_service.dart (Update startTestAttempt method)

// Start test attempt
  Future<Map<String, dynamic>> startTestAttempt(String seriesSlug, String testId) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/start');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'slug': seriesSlug,      // Changed from seriesSlug to slug
          'testId': testId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 402) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Payment required');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to start test');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit answer
  Future<Map<String, dynamic>> submitAnswer(String attemptId, String questionId, String selectedOption) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/answer');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'questionId': questionId,
          'selectedOption': selectedOption,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit answer');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Mark question for review
  Future<Map<String, dynamic>> markQuestion(String attemptId, String questionId, bool marked) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/mark');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'questionId': questionId,
          'marked': marked,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark question');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get token from storage
  Future<String> _getToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  // lib/services/api_service.dart (Add this method)

// Sync answers (save all answers at once)
  Future<Map<String, dynamic>> syncAnswers(String attemptId, List<Map<String, dynamic>> answers) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/sync');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'answers': answers,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to sync answers');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

// Submit test (final submission)
  Future<Map<String, dynamic>> submitTest(String attemptId) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/submit');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit test');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
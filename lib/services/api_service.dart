// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simplylawgic/services/storage_service.dart'; // Add this import
import '../models/student_model.dart';
import '../models/subject_notes.dart';
import '../models/test_series.dart';

import 'dart:io';
import 'package:http_parser/http_parser.dart'; // Add this import at top

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

  // Get student dashboard analytics
  Future<Map<String, dynamic>> getStudentAnalytics({int limit = 50}) async {
    final url = Uri.parse('$baseUrl/student/dashboard/analytics?limit=$limit');

    try {
      final token = await _getToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  //profile section
  // ============ CHANGE PHONE ============

// Send OTP to new phone number
  Future<Map<String, dynamic>> changePhoneSendOtp(String phone) async {
    final url = Uri.parse('$baseUrl/student/auth/change-phone/send-otp');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'phone': phone,
        }),
      );

      print('changePhoneSendOtp status: ${response.statusCode}');
      print('changePhoneSendOtp body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

// Verify OTP and update phone
  Future<Map<String, dynamic>> changePhoneVerify(
      String phone, String otp) async {
    final url = Uri.parse('$baseUrl/student/auth/change-phone/verify');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'phone': phone,
          'otp': otp,
        }),
      );

      print('changePhoneVerify status: ${response.statusCode}');
      print('changePhoneVerify body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save new token if provided
        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  // ============ CHANGE EMAIL ============

// Step 1: Send OTP to confirm new email
  Future<Map<String, dynamic>> changeEmailSendOtp(String email) async {
    final url = Uri.parse('$baseUrl/student/auth/change-email/send-otp');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
        }),
      );

      print('changeEmailSendOtp status: ${response.statusCode}');
      print('changeEmailSendOtp body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

// Step 2: Verify OTP and update email
  Future<Map<String, dynamic>> changeEmailVerify(
      String email, String otp) async {
    final url = Uri.parse('$baseUrl/student/auth/change-email/verify');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      print('changeEmailVerify status: ${response.statusCode}');
      print('changeEmailVerify body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save new token
        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }

        // Save updated student object
        if (data['student'] != null) {
          // Agar aapke StorageService mein saveStudent method hai toh:
          // await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }


// ============ UPLOAD AVATAR ============

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final url = Uri.parse('$baseUrl/student/auth/avatar');

    try {
      final token = await _getToken();

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add file with proper content type
      final extension = imageFile.path.split('.').last.toLowerCase();
      MediaType contentType;

      switch (extension) {
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        case 'jpg':
        case 'jpeg':
        default:
          contentType = MediaType('image', 'jpeg');
          break;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // API field name
          imageFile.path,
          contentType: contentType,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('uploadAvatar status: ${response.statusCode}');
      print('uploadAvatar body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save new token
        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }

        // Save updated student
        if (data['student'] != null) {
          await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
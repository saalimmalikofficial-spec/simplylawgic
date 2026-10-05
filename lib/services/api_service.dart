// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:simplylawgic/models/attempt_statusResponse.dart';
import 'package:simplylawgic/models/purchaseItem.dart';
import 'package:simplylawgic/services/storage_service.dart';
import '../models/student_model.dart';
import '../models/study_video.dart' show StudyVideoDetail, StudyVideo;
import '../models/subject_notes.dart';
import '../models/test_series.dart';

class ApiService {
  static const String baseUrl =
      'https://simply-lawgic-75585420080.asia-south1.run.app/api';
  final StorageService _storage = StorageService();

  // ============ AUTH ============

  // Sign in
  Future<SignInResponse> signIn(String email, String password) async {
    final url = Uri.parse('$baseUrl/student/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final signIn = SignInResponse.fromJson(data);

        // 👇 Auto-save everything to storage
        await _storage.saveToken(signIn.token);
        await _storage.saveStudent(signIn.student);
        await _storage.saveProfileComplete(signIn.profileComplete);

        return signIn;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Sign in failed');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  // ============ GOOGLE SIGN-IN ============

  // Sign in / sign up with Google ID Token
// ============ GOOGLE SIGN-IN ============

  Future<SignInResponse> googleSignIn(String idToken) async {
    final url = Uri.parse('$baseUrl/student/auth/google');

    print('');
    print('========================================');
    print('API: GOOGLE SIGN-IN');
    print('========================================');

    print('API URL: $url');
    print('API METHOD: POST');

    print('API: Preparing request body...');

    final requestBody = {
      'idToken': idToken,
    };

    print('API BODY:');
    print('{');
    print('  idToken: [TOKEN RECEIVED]');
    print('}');

    try {
      print('API: Sending Google ID Token to backend...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('');
      print('API: Response received');
      print('API STATUS CODE: ${response.statusCode}');
      print('API RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        print('API: Google login SUCCESS');

        final Map<String, dynamic> data =
        json.decode(response.body);

        print('API: Response JSON parsed');

        final signIn = SignInResponse.fromJson(data);

        print('API: SignInResponse created');

        print('API: Saving token...');
        await _storage.saveToken(signIn.token);

        print('API: Saving student...');
        await _storage.saveStudent(signIn.student);

        print('API: Saving profile completion...');
        await _storage.saveProfileComplete(
          signIn.profileComplete,
        );

        print('API: All login data saved');
        print('API: GOOGLE LOGIN COMPLETED');

        print('========================================');

        return signIn;
      } else {
        print('API: Google login FAILED');

        Map<String, dynamic> errorData = {};

        try {
          errorData = json.decode(response.body);
        } catch (_) {
          print('API: Response is not valid JSON');
        }

        final message =
            errorData['message'] ??
                'Google sign-in failed';

        print('API ERROR MESSAGE: $message');

        throw Exception(message);
      }
    } on Exception {
      print('API: Exception occurred');
      rethrow;
    } catch (e) {
      print('API: Network/Unknown error');
      print('API ERROR: $e');

      throw Exception(
        'Network error: ${e.toString()}',
      );
    }
  }

  // Send OTP (login/signup)
  Future<Map<String, dynamic>> sendOTP(String phone) async {
    final url = Uri.parse('$baseUrl/student/auth/phone/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify OTP (login/signup)
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
    final url = Uri.parse('$baseUrl/student/auth/phone/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'otp': otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Sign up
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> signupData) async {
    final url = Uri.parse('$baseUrl/student/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Signup failed');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ SUBJECT NOTES ============

  // Get all subject-wise notes
  Future<List<SubjectNotes>> getSubjectNotes() async {
    final url = Uri.parse('$baseUrl/subject-wise-notes/public');

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
        final List<dynamic> data = json.decode(response.body);
        return SubjectNotes.fromJsonList(data);
      } else {
        throw Exception('Failed to load subject notes');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get single subject note by slug
  Future<SubjectNotes> getSubjectNoteBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/subject-wise-notes/public/$slug');

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
        final Map<String, dynamic> data = json.decode(response.body);
        return SubjectNotes.fromJson(data);
      } else {
        throw Exception('Failed to load note details');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ TEST SERIES ============

  // Get all test series
  Future<List<TestSeries>> getTestSeries() async {
    final url = Uri.parse('$baseUrl/test-series/public');

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
        final List<dynamic> data = json.decode(response.body);
        return TestSeries.fromJsonList(data);
      } else {
        throw Exception('Failed to load test series');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get single test series by slug
  Future<TestSeries> getTestSeriesBySlug(String slug) async {
    final url = Uri.parse('$baseUrl/test-series/public/$slug');

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
        final Map<String, dynamic> data = json.decode(response.body);
        return TestSeries.fromJson(data);
      } else {
        throw Exception('Failed to load test series details');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ TEST ATTEMPT ============

  // Start test attempt
  Future<Map<String, dynamic>> startTestAttempt(
      String seriesSlug, String testId) async {
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
          'slug': seriesSlug,
          'testId': testId,
        }),
      );

      print('startTestAttempt status: ${response.statusCode}');
      print('startTestAttempt body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 402) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Payment required');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to start test');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit single answer
  Future<Map<String, dynamic>> submitAnswer(
      String attemptId, String questionId, String selectedOption) async {
    final url =
    Uri.parse('$baseUrl/test-series/attempts/$attemptId/answer');

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
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Mark question for review
  Future<Map<String, dynamic>> markQuestion(
      String attemptId, String questionId, bool marked) async {
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
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Sync all answers at once
  Future<Map<String, dynamic>> syncAnswers(
      String attemptId, List<Map<String, dynamic>> answers) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/sync');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'answers': answers}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to sync answers');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

// Submit test (final)
  Future<Map<String, dynamic>> submitTest(
      String attemptId, {
        List<Map<String, dynamic>>? answers,
      }) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/submit');

    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {};
      if (answers != null && answers.isNotEmpty) {
        body['answers'] = answers;
      }

      print('');
      print('========================================');
      print('API: SUBMIT TEST');
      print('========================================');
      print('API URL: $url');
      print('API BODY: $body');
      print('========================================');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('API STATUS: ${response.statusCode}');
      print('API RESPONSE: ${response.body}');
      print('========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit test');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ ANALYTICS ============

  // Student dashboard analytics
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
        final data = json.decode(response.body) as Map<String, dynamic>;

        // 👇 Profile ko local storage mein bhi save kar do
        final profileJson = data['profile'];
        if (profileJson != null && profileJson is Map<String, dynamic>) {
          try {
            await _storage.saveStudent(Student.fromJson(profileJson));
          } catch (_) {}
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch analytics');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

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
        body: json.encode({'phone': phone}),
      );

      print('changePhoneSendOtp status: ${response.statusCode}');
      print('changePhoneSendOtp body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify OTP and update phone
  Future<Map<String, dynamic>> changePhoneVerify(
      String phone, String otp) async
  {
    final url = Uri.parse('$baseUrl/student/auth/change-phone/verify');

    try {
      final token = await _getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'phone': phone, 'otp': otp}),
      );

      print('changePhoneVerify status: ${response.statusCode}');
      print('changePhoneVerify body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }
        if (data['student'] != null) {
          await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } on Exception {
      rethrow;
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
        body: json.encode({'email': email}),
      );

      print('changeEmailSendOtp status: ${response.statusCode}');
      print('changeEmailSendOtp body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } on Exception {
      rethrow;
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
        body: json.encode({'email': email, 'otp': otp}),
      );

      print('changeEmailVerify status: ${response.statusCode}');
      print('changeEmailVerify body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }
        if (data['student'] != null) {
          await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify OTP');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ UPLOAD AVATAR ============

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final url = Uri.parse('$baseUrl/student/auth/avatar');

    try {
      final token = await _getToken();

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

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
          'avatar',
          imageFile.path,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('uploadAvatar status: ${response.statusCode}');
      print('uploadAvatar body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }
        if (data['student'] != null) {
          await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload avatar');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ UPDATE PROFILE ============

  /// Update student profile (name, preparingForExam, etc.)
  /// POST /api/student/auth/profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String preparingForExam,
  }) async {
    final url = Uri.parse('$baseUrl/student/auth/profile');

    try {
      final token = await _getToken();
      final response = await http.patch(          // 👈 POST → PATCH
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'preparingForExam': preparingForExam,
        }),
      );

      print('updateProfile status: ${response.statusCode}');
      print('updateProfile body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['token'] != null) {
          await _storage.saveToken(data['token']);
        }
        if (data['student'] != null) {
          await _storage.saveStudent(Student.fromJson(data['student']));
        }

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ FORGOT PASSWORD ============

  // Step 1: Send OTP to registered phone
  Future<Map<String, dynamic>> forgotPasswordSendOtp(String phone) async {
    final url = Uri.parse('$baseUrl/student/auth/forgot-password/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      print('forgotPasswordSendOtp status: ${response.statusCode}');
      print('forgotPasswordSendOtp body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send OTP');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Step 2: Reset password with OTP
  Future<Map<String, dynamic>> forgotPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/student/auth/forgot-password/reset');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      print('forgotPasswordReset status: ${response.statusCode}');
      print('forgotPasswordReset body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ CHECKOUT SESSION (PAID CONTENT) ============

  Future<Map<String, dynamic>> createCheckoutSession({
    required String type,
    required String slug,
    String? referralCode,
    String returnUrl = 'simplylawgic://purchase',
  }) async {
    final url = Uri.parse('$baseUrl/student/app/checkout-session');

    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        'type': type,
        'slug': slug,
        'returnUrl': returnUrl,
        'referralCode': (referralCode ?? '').trim(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('');
      print('========================================');
      print('API: CHECKOUT SESSION');
      print('========================================');
      print('API URL: $url');
      print('API BODY: $body');
      print('API STATUS: ${response.statusCode}');
      print('API RESPONSE: ${response.body}');
      print('========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to create checkout session',
        );
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ CHECKOUT SESSION — SUBJECT NOTES ============
  Future<Map<String, dynamic>> createNotesCheckoutSession({
    required String noteId,
    required String blockId,
    String? referralCode,
    String returnUrl = 'simplylawgic://purchase',
  }) async {
    final url = Uri.parse('$baseUrl/student/app/checkout-session');

    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        'type': 'notes-subject',
        'noteId': noteId,
        'blockId': blockId,
        'returnUrl': returnUrl,
        'referralCode': (referralCode ?? '').trim(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('');
      print('========================================');
      print('API: NOTES CHECKOUT SESSION');
      print('========================================');
      print('API URL: $url');
      print('API BODY: $body');
      print('API STATUS: ${response.statusCode}');
      print('API RESPONSE: ${response.body}');
      print('========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to create checkout session',
        );
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Your Purchases
  // ─────────────────────────────────────────────────────────────
  Future<PurchasesResponse> getMyPurchases() async {
    final url = Uri.parse('$baseUrl/student/account/purchases');
    final token = await _storage.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PurchasesResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load purchases');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============ DELETE ACCOUNT ============
  Future<String> deleteAccount(String reason) async {
    final url = Uri.parse('$baseUrl/student/account/delete');
    final token = await _storage.getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['message'] ??
            'Your profile has been deleted successfully.';
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete account');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<AttemptStatusResponse> getAttemptStatus({
    required String slug,
    required String testId,
    String? resumeToken,
  }) async {
    final queryParams = <String, String>{
      'slug': slug,
      'testId': testId,
    };

    if (resumeToken != null && resumeToken.isNotEmpty) {
      queryParams['resumeToken'] = resumeToken;
    }

    final uri = Uri.parse('$baseUrl/test-series/attempts/status')
        .replace(queryParameters: queryParams);

    try {
      final token = await _storage.getToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AttemptStatusResponse.fromJson(data);
      } else {
        // Try to parse server error message
        String message = 'Failed to fetch attempt status';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            message = errorData['message'].toString();
          }
        } catch (_) {}
        throw Exception(message);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ============================================================
  // ✅ GET ATTEMPT REPORT
  // GET /api/test-series/attempts/{{attemptId}}/report
  // ============================================================
  Future<Map<String, dynamic>> getAttemptReport(String attemptId) async {
    final url = Uri.parse('$baseUrl/test-series/attempts/$attemptId/report');

    try {
      final token = await _storage.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String message = 'Failed to fetch report';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            message = errorData['message'].toString();
          }
        } catch (_) {}
        throw Exception(message);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  // ======================================================
// GET ALL PUBLIC STUDY VIDEOS
// ======================================================

  Future<List<StudyVideo>> getStudyVideos() async {
    final url = Uri.parse('$baseUrl/study-videos/public');

    try {
      final token = await _getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is! List) {
          throw Exception('Invalid study videos response');
        }

        return decoded
            .map(
              (item) => StudyVideo.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      throw Exception(
        'Failed to load study videos (${response.statusCode})',
      );
    } catch (e) {
      throw Exception(
        'Unable to load study videos: ${e.toString()}',
      );
    }
  }


// ======================================================
// GET SINGLE STUDY VIDEO BY SLUG
// ======================================================

  Future<StudyVideoDetail> getStudyVideoBySlug(String slug) async {
    final encodedSlug = Uri.encodeComponent(slug);

    final url = Uri.parse(
      '$baseUrl/study-videos/public/$encodedSlug',
    );

    try {
      final token = await _getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          json.decode(response.body),
        );

        return StudyVideoDetail.fromJson(data);
      }

      throw Exception(
        'Failed to load video details (${response.statusCode})',
      );
    } catch (e) {
      throw Exception(
        'Unable to load video details: ${e.toString()}',
      );
    }
  }

  // ============ TOKEN HELPER ============

  Future<String> _getToken() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return token;
  }
}
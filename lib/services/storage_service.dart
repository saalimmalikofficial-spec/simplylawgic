// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED
import '../models/student_model.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String studentKey = 'student_data';
  static const String profileCompleteKey = 'profile_complete';
  static const String themeKey = 'theme_preference';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ============ TEST ATTEMPT STATE ============
  // ✅ NOTE: SharedPreferences use kiya kyunki yeh non-sensitive data hai
  // (FlutterSecureStorage bhi use kar sakte the, but SP fast hai)

  static const String _keyStartedTests = 'started_test_ids';

  /// Save karo ki user ne yeh test start kar diya hai
  Future<void> markTestStarted(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> started = prefs.getStringList(_keyStartedTests) ?? [];
    if (!started.contains(testId)) {
      started.add(testId);
      await prefs.setStringList(_keyStartedTests, started);
    }
  }

  /// Check karo ki user ne yeh test pehle start kiya tha kya
  Future<bool> hasTestStarted(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> started = prefs.getStringList(_keyStartedTests) ?? [];
    return started.contains(testId);
  }

  /// Test submit hone par remove karo
  Future<void> clearTestStarted(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> started = prefs.getStringList(_keyStartedTests) ?? [];
    started.remove(testId);
    await prefs.setStringList(_keyStartedTests, started);
  }

  /// Logout par sab clear karo
  Future<void> clearAllStartedTests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStartedTests);
  }

  // ============ TOKEN ============
  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  // ============ STUDENT ============
  Future<void> saveStudent(Student student) async {
    await _storage.write(
      key: studentKey,
      value: json.encode({
        'id': student.id,
        'name': student.name,
        'email': student.email,
        'phone': student.phone,
        'preparingForExam': student.preparingForExam,
        'preparingForExamLabel': student.preparingForExamLabel,
        'authProvider': student.authProvider,
        'avatarUrl': student.avatarUrl,
        'referralCode': student.referralCode,
        'walletBalance': student.walletBalance,
      }),
    );
  }

  Future<Student?> getStudent() async {
    final String? studentJson = await _storage.read(key: studentKey);
    if (studentJson != null) {
      try {
        final Map<String, dynamic> data = json.decode(studentJson);
        return Student.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ============ THEME ============
  Future<void> saveThemePreference(bool isDark) async {
    await _storage.write(key: themeKey, value: isDark.toString());
  }

  Future<bool?> getThemePreference() async {
    final String? value = await _storage.read(key: themeKey);
    if (value != null) return value == 'true';
    return null;
  }

  // ============ PROFILE COMPLETE ============
  Future<void> saveProfileComplete(bool complete) async {
    await _storage.write(key: profileCompleteKey, value: complete.toString());
  }

  Future<bool> getProfileComplete() async {
    final String? value = await _storage.read(key: profileCompleteKey);
    return value == 'true';
  }

  // ============ AUTH CHECK ============
  Future<bool> isLoggedIn() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============ CONVENIENCE ============
  Future<void> saveSignInResponse(Map<String, dynamic> response) async {
    final token = response['token'];
    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }

    final studentJson = response['student'];
    if (studentJson is Map<String, dynamic>) {
      final student = Student.fromJson(studentJson);
      await saveStudent(student);
    }

    final profileComplete = response['profileComplete'];
    if (profileComplete is bool) {
      await saveProfileComplete(profileComplete);
    }
  }

  // ============ CLEAR ALL (logout) ============
  Future<void> clearAll() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: studentKey);
    await _storage.delete(key: profileCompleteKey);
    await _storage.delete(key: themeKey);
    // ✅ Also clear started tests on logout
    await clearAllStartedTests();
  }
}
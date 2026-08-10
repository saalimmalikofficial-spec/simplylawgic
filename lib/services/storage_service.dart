// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/student_model.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String studentKey = 'student_data';
  static const String profileCompleteKey = 'profile_complete';
  static const String themeKey = 'theme_preference'; // Add this

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Token methods
  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  // Student methods
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
        })
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

  // Theme preference methods - Add these
  Future<void> saveThemePreference(bool isDark) async {
    await _storage.write(key: themeKey, value: isDark.toString());
  }

  Future<bool?> getThemePreference() async {
    final String? value = await _storage.read(key: themeKey);
    if (value != null) {
      return value == 'true';
    }
    return null;
  }

  // Profile complete methods
  Future<void> saveProfileComplete(bool complete) async {
    await _storage.write(key: profileCompleteKey, value: complete.toString());
  }

  Future<bool> getProfileComplete() async {
    final String? value = await _storage.read(key: profileCompleteKey);
    return value == 'true';
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: studentKey);
    await _storage.delete(key: profileCompleteKey);
    await _storage.delete(key: themeKey); // Add this
  }
}
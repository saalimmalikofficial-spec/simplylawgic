// lib/services/student_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:simplylawgic/models/student_model.dart';

/// Global student notifier
/// Jab bhi student update hota hai, saare listeners ko pata chalta hai.
/// Isse ek screen se change karne pe doosri screen auto-refresh hoti hai.
class StudentNotifier {
  StudentNotifier._();

  static final StudentNotifier instance = StudentNotifier._();

  /// Global ValueNotifier — student ka current data
  final ValueNotifier<Student?> student = ValueNotifier<Student?>(null);

  /// Update student — har jagah se call karo
  void update(Student? s) {
    student.value = s;
  }

  /// Get current student
  Student? get current => student.value;
}
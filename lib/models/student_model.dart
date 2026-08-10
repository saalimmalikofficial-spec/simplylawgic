// lib/models/student_model.dart
class Student {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String preparingForExam;
  final String preparingForExamLabel;
  final String authProvider;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.preparingForExam,
    required this.preparingForExamLabel,
    required this.authProvider,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      preparingForExam: json['preparingForExam'] ?? '',
      preparingForExamLabel: json['preparingForExamLabel'] ?? '',
      authProvider: json['authProvider'] ?? '',
    );
  }
}

// lib/models/sign_in_response.dart
class SignInResponse {
  final String message;
  final String token;
  final Student student;
  final bool profileComplete;

  SignInResponse({
    required this.message,
    required this.token,
    required this.student,
    required this.profileComplete,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      student: Student.fromJson(json['student'] ?? {}),
      profileComplete: json['profileComplete'] ?? false,
    );
  }
}
// lib/models/student_model.dart
class Student {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String preparingForExam;
  final String preparingForExamLabel;
  final String authProvider;
  final String? avatarUrl;
  final String? referralCode;
  final num? walletBalance;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.preparingForExam,
    required this.preparingForExamLabel,
    required this.authProvider,
    this.avatarUrl,
    this.referralCode,
    this.walletBalance,
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
      avatarUrl: json['avatarUrl'],
      referralCode: json['referralCode'],
      walletBalance: json['walletBalance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'preparingForExam': preparingForExam,
      'preparingForExamLabel': preparingForExamLabel,
      'authProvider': authProvider,
      'avatarUrl': avatarUrl,
      'referralCode': referralCode,
      'walletBalance': walletBalance,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? preparingForExam,
    String? preparingForExamLabel,
    String? authProvider,
    String? avatarUrl,
    String? referralCode,
    num? walletBalance,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      preparingForExam: preparingForExam ?? this.preparingForExam,
      preparingForExamLabel:
      preparingForExamLabel ?? this.preparingForExamLabel,
      authProvider: authProvider ?? this.authProvider,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      referralCode: referralCode ?? this.referralCode,
      walletBalance: walletBalance ?? this.walletBalance,
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
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
  final String? accountStatus;
  final bool? profileComplete;

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
    this.accountStatus,
    this.profileComplete,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      preparingForExam: json['preparingForExam']?.toString() ?? '',
      preparingForExamLabel:
      json['preparingForExamLabel']?.toString() ?? '',
      authProvider: json['authProvider']?.toString() ?? 'local',
      avatarUrl: json['avatarUrl']?.toString(),
      referralCode: json['referralCode']?.toString(),
      walletBalance: _parseNum(json['walletBalance']),
      accountStatus: json['accountStatus']?.toString(),
      profileComplete: json['profileComplete'] is bool
          ? json['profileComplete'] as bool
          : null,
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
      'accountStatus': accountStatus,
      'profileComplete': profileComplete,
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
    String? accountStatus,
    bool? profileComplete,
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
      accountStatus: accountStatus ?? this.accountStatus,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  // Safe numeric parsing
  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  // Formatted wallet balance (Indian format)
  String get formattedWalletBalance {
    final balance = walletBalance?.toInt() ?? 0;
    final str = balance.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final otherNumbers = str.substring(0, str.length - 3);
    final formatted = otherNumbers.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
          (m) => '${m[1]},',
    );
    return '$formatted,$lastThree';
  }

  // Avatar fallback initial
  String get initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

  @override
  String toString() =>
      'Student(id: $id, name: $name, email: $email, wallet: $walletBalance)';
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
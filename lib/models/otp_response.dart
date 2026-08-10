// lib/models/otp_response.dart
class SendOTPResponse {
  final String message;
  final String phone;
  final int expiresInSeconds;

  SendOTPResponse({
    required this.message,
    required this.phone,
    required this.expiresInSeconds,
  });

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      message: json['message'] ?? '',
      phone: json['phone'] ?? '',
      expiresInSeconds: json['expiresInSeconds'] ?? 0,
    );
  }
}

class VerifyOTPResponse {
  final String message;
  final String phone;
  final String phoneVerificationToken;

  VerifyOTPResponse({
    required this.message,
    required this.phone,
    required this.phoneVerificationToken,
  });

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      message: json['message'] ?? '',
      phone: json['phone'] ?? '',
      phoneVerificationToken: json['phoneVerificationToken'] ?? '',
    );
  }
}
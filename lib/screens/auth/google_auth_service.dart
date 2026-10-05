import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Google Sign-In for the Flutter app.
///
/// Uses the **Firebase Web client (type 3)** as `serverClientId`.
/// Do not use the website GIS client (`75585420080-…`) here — that is a
/// different Google Cloud project and will break Android tokens.
///
/// Backend: `POST /api/student/auth/google`
/// Website keeps `VITE_GOOGLE_CLIENT_ID`; backend also allows this Web client
/// via `GOOGLE_CLIENT_IDS`.
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  /// OAuth Web client from google-services.json (`client_type`: 3).
  static const String serverClientId =
      '290991641035-pj5nk604ln9buo6v72t7d48iaas79abk.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  /// Google account picker → backend-verifiable ID token.
  /// Do not `print` the full token (Android logcat splits it and Postman then fails).
  Future<String> signInAndGetIdToken() async {
    await initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception('Google Sign-In is not supported on this platform');
    }

    final GoogleSignInAccount user = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'openid', 'profile'],
    );

    final String? idToken = user.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID Token was not received');
    }

    return idToken;
  }

  /// Same API as the website: returns `{ token, student, profileComplete, message }`.
  Future<Map<String, dynamic>> signInWithBackend({
    required String apiBaseUrl,
    String? referralCode,
  }) async {
    final idToken = await signInAndGetIdToken();
    final base = apiBaseUrl.replaceAll(RegExp(r'/+$'), '');

    final response = await http.post(
      Uri.parse('$base/api/student/auth/google'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        if (referralCode != null && referralCode.trim().isNotEmpty)
          'referralCode': referralCode.trim(),
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Google sign-in failed (${response.statusCode})';
      throw Exception(message);
    }

    return Map<String, dynamic>.from(body as Map);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
/*import 'package:internship_app/services/fcm_token_service.dart';

class AuthService {
  Future<String> login(String email, String password) async {
    final response = await apiService.login(email, password);

    final String authToken = response.token;

    // Send FCM token to backend
    await FCMTokenService.sendTokenToBackend(authToken);
    FCMTokenService.listenToTokenRefresh(authToken);

    return authToken;
  }
}*/


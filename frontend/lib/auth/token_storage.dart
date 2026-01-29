import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for device-level credentials.
/// 
/// Stores ONLY the ESP32 device token obtained after BLE onboarding.
/// - Encrypted at OS level (Android Keystore / iOS Keychain)
/// - Survives app restarts
/// - Revocable by logout / reset
class TokenStorage {
  // Single secure storage instance
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // Key used to store the ESP32 / device token
  static const String _deviceTokenKey = 'device_token';

  /// Save device token after successful BLE onboarding
  static Future<void> saveDeviceToken(String token) async {
    await _storage.write(
      key: _deviceTokenKey,
      value: token,
    );
  }

  /// Retrieve device token (null if not paired)
  static Future<String?> getDeviceToken() async {
    return await _storage.read(
      key: _deviceTokenKey,
    );
  }

  /// Delete device token (logout / reset device)
  static Future<void> deleteDeviceToken() async {
    await _storage.delete(
      key: _deviceTokenKey,
    );
  }

  /// Convenience check
  static Future<bool> hasDeviceToken() async {
    return (await getDeviceToken()) != null;
  }
}

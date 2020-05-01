import 'package:biometric_storage/biometric_storage.dart';

class EncryptedAuthStorageService {
  final String _authStorageFile = 'bio-auth-storage';

  Future<bool> canAuthenticate() async {
    return await BiometricStorage().canAuthenticate() ==
        CanAuthenticateResponse.success;
  }

  Future<BiometricStorageFile> _getStorage(key) async {
    return await BiometricStorage().getStorage(_authStorageFile + key);
  }

  Future<void> writeString(String key, String value) async {
    return (await _getStorage(key)).write(value);
  }

  Future<String> readString(String key) async {
    return (await _getStorage(key)).read();
  }
}

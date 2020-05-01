
import 'package:biometric_storage/biometric_storage.dart';
import 'package:universal_platform/universal_platform.dart';

class EncryptedAuthStorageService {
  final String _authStorageFile = 'bio-auth-storage-';
  final String _credentialsStorageKey = 'credentials-key';

  Future<bool> canAuthenticate() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      return await BiometricStorage().canAuthenticate() ==
          CanAuthenticateResponse.success;
    } else {
      return false;
    }
  }

  Future<BiometricStorageFile> _getCredentialsStorage() async {
    return await BiometricStorage().getStorage(_authStorageFile + _credentialsStorageKey);
  }

  Future<void> storeCredentials(String username, String password) async {
    String value = '$username:$password';
    return (await _getCredentialsStorage()).write(value);
  }

  Future<List<String>> loadCredentials() async {
    String credentials = await (await _getCredentialsStorage()).read();
    return credentials.split(':');
  }

  Future deleteCredentials() async {
    return (await _getCredentialsStorage()).delete();
  }
}

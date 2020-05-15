import 'package:biometric_storage/biometric_storage.dart';
import 'package:universal_platform/universal_platform.dart';

class EncryptedAuthStorageService {
  final String _authStorageFile = 'bio-auth-storage-';
  final String _credentialsStorageKey = 'credentials-key';

  final AndroidPromptInfo androidPromptInfoLogin = AndroidPromptInfo(
      title: 'Biometric login.', subtitle: 'Use your biometric info to login.');

  final AndroidPromptInfo androidPromptInfoStoreCredentials = AndroidPromptInfo(
      title: 'Confirm biometric login.',
      subtitle: 'Use your biometric info to login next time?');

  Future<bool> canAuthenticate() async {
    if (UniversalPlatform.isAndroid ||
        UniversalPlatform.isIOS ||
        UniversalPlatform.isMacOS) {
      return await BiometricStorage().canAuthenticate() ==
          CanAuthenticateResponse.success;
    } else {
      return false;
    }
  }

  Future<BiometricStorageFile> _getCredentialsStorage(
      bool loadingCredentials) async {
    return await BiometricStorage().getStorage(
        _authStorageFile + _credentialsStorageKey,
        androidPromptInfo: loadingCredentials
            ? androidPromptInfoLogin
            : androidPromptInfoStoreCredentials);
  }

  Future<void> storeCredentials(String username, String password) async {
    String value = '$username:$password';
    return (await _getCredentialsStorage(false)).write(value);
  }

  Future<List<String>> loadCredentials() async {
    String credentials = await (await _getCredentialsStorage(true)).read();
    return credentials.split(':');
  }

  Future deleteCredentials() async {
    return (await _getCredentialsStorage(true)).delete();
  }
}

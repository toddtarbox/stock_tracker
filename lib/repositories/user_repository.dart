import 'dart:async';

import 'package:meta/meta.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart/cognito.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/services/encrypted_auth_storage_service.dart';

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'us-east-2_TzvJJcJUp';
const _awsClientId = '19qmv49jfbr7jfhojgoc71c2oc';

class UserRepository {
  final UserApiClient userApiClient;

  final CognitoUserPool _userPool = new CognitoUserPool(_awsUserPoolId, _awsClientId);
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  CognitoCredentials credentials;

  final EncryptedAuthStorageService encryptedAuthStorageService = EncryptedAuthStorageService();

  UserRepository({@required this.userApiClient})
      : assert(userApiClient != null);

  Future<bool> _isBioAuthConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('bio-auth-configured') && prefs.getBool('bio-auth-configured');
  }

  Future<bool> _canBioAuthAuthenticate() async {
    return encryptedAuthStorageService.canAuthenticate();
  }

  Future _setBioAuthConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool('bio-auth-configured', configured);
  }

  /// Initiate user session from encrypted storage, if present
  Future<bool> init() async {
    final isBiometricAuthConfigured = await _isBioAuthConfigured();
    if (isBiometricAuthConfigured) {
      List<String> savedUsernamePassword = await encryptedAuthStorageService.loadCredentials();
      if (savedUsernamePassword != null && savedUsernamePassword.length == 2) {
        try {
          await authenticate(username: savedUsernamePassword[0], password: savedUsernamePassword[1]);
        } on CognitoClientException catch (e) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    } else {
      _cognitoUser = await _userPool.getCurrentUser();
      if (_cognitoUser == null) {
        return false;
      }
      _session = await _cognitoUser.getSession();
      return _session.isValid();
    }
  }

  /// Get existing user from session with his/her attributes
  Future<User> getCurrentUser() async {
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    if (!_session.isValid()) {
      return null;
    }
    final attributes = await _cognitoUser.getUserAttributes();
    if (attributes == null) {
      return null;
    }
    final user = new User.fromUserAttributes(attributes);
    user.hasAccess = true;
    return user;
  }

  Future<User> authenticate({
    @required String username,
    @required String password,
  }) async {
    _cognitoUser =
        new CognitoUser(username, _userPool);

    final authDetails = new AuthenticationDetails(
      username: username,
      password: password,
    );

    bool isConfirmed;
    try {
      _session = await _cognitoUser.authenticateUser(authDetails);
      isConfirmed = true;
    } on CognitoClientException catch (e) {
      if (e.code == 'UserNotConfirmedException') {
        isConfirmed = false;
      } else {
        throw e;
      }
    }

    if (!_session.isValid()) {
      return null;
    }

    final attributes = await _cognitoUser.getUserAttributes();
    final user = new User.fromUserAttributes(attributes);
    user.confirmed = isConfirmed;
    user.hasAccess = true;

    final isBiometricAuthConfigured = await _isBioAuthConfigured();
    final canBioAuthAuthenticate = await _canBioAuthAuthenticate();
    if (!isBiometricAuthConfigured && canBioAuthAuthenticate) {
      try {
        await encryptedAuthStorageService.storeCredentials(username, password);
        await _setBioAuthConfigured(true);
      } on Exception catch (e) {
        // User canceled biometric prompt, ignore
      }
    }

    return user;
  }

  /// Confirm user's account with confirmation code sent to email
  Future<bool> confirmAccount(String username, String confirmationCode) async {
    _cognitoUser =
        new CognitoUser(username, _userPool);

    return await _cognitoUser.confirmRegistration(confirmationCode);
  }

  /// Resend confirmation code to user's email
  Future<void> resendConfirmationCode(String email) async {
    _cognitoUser =
        new CognitoUser(email, _userPool);
    await _cognitoUser.resendConfirmationCode();
  }

  /// Check if user's current session is valid
  Future<bool> checkAuthenticated() async {
    if (_cognitoUser == null || _session == null) {
      return false;
    }
    return _session.isValid();
  }

  /// Sign up new user
  Future<User> signUp({
    @required String name,
    @required String email,
    @required String username,
    @required String password,
  }) async {
    CognitoUserPoolData data;
    final userAttributes = [
      new AttributeArg(name: 'email', value: email),
      new AttributeArg(name: 'name', value: name),
    ];
    data = await _userPool.signUp(username, password,
        userAttributes: userAttributes);

    final user = new User();
    user.username = username;
    user.name = name;
    user.email = email;
    user.confirmed = data.userConfirmed;

    return user;
  }

  Future<void> signOut() async {
    if (credentials != null) {
      await credentials.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      await _cognitoUser.signOut();
    }
    await _setBioAuthConfigured(false);
  }
}

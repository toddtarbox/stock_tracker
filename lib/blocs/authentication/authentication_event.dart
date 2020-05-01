import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
}

class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => null;
}

class LoggedIn extends AuthenticationEvent {
  @override
  List<Object> get props => null;
}

class LoggedInConfirm extends AuthenticationEvent {
  @override
  List<Object> get props => null;
}

class LoggedOut extends AuthenticationEvent {
  @override
  List<Object> get props => null;
}

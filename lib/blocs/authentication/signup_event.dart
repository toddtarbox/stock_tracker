import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
}

class SignUpButtonPressed extends SignUpEvent {
  final String name;
  final String email;
  final String username;
  final String password;

  const SignUpButtonPressed({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [name, email, username, password];

  @override
  String toString() =>
      'SignUpButtonPressed { name: $name, email: $email, username: $username, password: $password }';
}

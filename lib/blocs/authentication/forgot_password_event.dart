import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
}

class ForgotPasswordButtonPressed extends ForgotPasswordEvent {
  final String name;
  final String username;
  final String password;

  const ForgotPasswordButtonPressed({
    @required this.name,
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [name, username, password];

  @override
  String toString() =>
      'ForgotPasswordButtonPressed { name: $name, username: $username, password: $password }';
}

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpConfirmationEvent extends Equatable {
  const SignUpConfirmationEvent();
}

class SignUpConfirmationButtonPressed extends SignUpConfirmationEvent {
  final String username;
  final String confirmationCode;

  const SignUpConfirmationButtonPressed({
    @required this.username,
    @required this.confirmationCode,
  });

  @override
  List<Object> get props => [username, confirmationCode];

  @override
  String toString() =>
      'SignUpConfirmationButtonPressed { username: $username, confirmationCode: $confirmationCode }';
}

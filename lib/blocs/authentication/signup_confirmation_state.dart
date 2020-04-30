import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpConfirmationState extends Equatable {
  const SignUpConfirmationState();

  @override
  List<Object> get props => [];
}

class SignUpConfirmationInitial extends SignUpConfirmationState {}

class SignUpConfirmationLoading extends SignUpConfirmationState {}

class SignUpConfirmationSuccess extends SignUpConfirmationState {}

class SignUpConfirmationFailure extends SignUpConfirmationState {
  final String error;

  const SignUpConfirmationFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'SignUpConfirmationFailure { error: $error }';
}

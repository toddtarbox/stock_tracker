import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  const ForgotPasswordFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'ForgotPasswordFailure { error: $error }';
}

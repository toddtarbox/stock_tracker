import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'SignUpFailure { error: $error }';
}

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/repositories/repositories.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  SignUpBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  SignUpState get initialState => SignUpInitial();

  @override
  Stream<SignUpState> mapEventToState(
    SignUpEvent event,
  ) async* {
    if (event is SignUpButtonPressed) {
      yield SignUpLoading();

      try {
        final User user = await userRepository.signUp(
          name: event.name,
          email: event.email,
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedInConfirm());
        yield SignUpSuccess();
      } catch (error) {
        yield SignUpFailure(error: error.toString());
      }
    }
  }
}

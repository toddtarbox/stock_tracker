import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/repositories/repositories.dart';

class SignUpConfirmationBloc
    extends Bloc<SignUpConfirmationEvent, SignUpConfirmationState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  SignUpConfirmationBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  SignUpConfirmationState get initialState => SignUpConfirmationInitial();

  @override
  Stream<SignUpConfirmationState> mapEventToState(
    SignUpConfirmationEvent event,
  ) async* {
    if (event is SignUpConfirmationButtonPressed) {
      yield SignUpConfirmationLoading();

      try {
        final bool confirmed = await userRepository.confirmAccount(
          event.username,
          event.confirmationCode,
        );

        authenticationBloc.add(LoggedIn());
        yield SignUpConfirmationSuccess();
      } catch (error) {
        yield SignUpConfirmationFailure(error: error.toString());
      }
    }
  }
}

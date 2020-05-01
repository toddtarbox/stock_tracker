import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/blocs/blocs.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      // Give splash screen some time to display
      await Future.delayed(Duration(seconds: 3));

      // Show the login screen
      yield AuthenticationUnauthenticated();

      // Will prompt for biometrics if necessary
      await userRepository.init();
      final bool isAuthenticated = await userRepository.checkAuthenticated();

      if (isAuthenticated) {
        yield AuthenticationLoading();
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      yield AuthenticationUnauthenticated();
      await userRepository.signOut();
    }
  }
}

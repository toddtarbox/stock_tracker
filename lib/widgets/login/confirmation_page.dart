import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/widgets.dart';

class ConfirmationPage extends StatefulWidget {
  final UserRepository userRepository;

  ConfirmationPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  _ConfirmationPageState createState() => new _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  SignUpConfirmationBloc _signUpConfirmationBloc;
  // ignore: close_sinks
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  final _usernameController = TextEditingController();
  final _confirmationCodeController = TextEditingController();

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _signUpConfirmationBloc = SignUpConfirmationBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  void submit() async {
    _signUpConfirmationBloc.add(SignUpConfirmationButtonPressed(
      username: _usernameController.text,
      confirmationCode: _confirmationCodeController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: BlocBuilder<SignUpConfirmationBloc, SignUpConfirmationState>(
        bloc: _signUpConfirmationBloc,
        builder: (
          BuildContext context,
          SignUpConfirmationState state,
        ) {
          if (state is SignUpConfirmationFailure) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          if (state is SignUpConfirmationSuccess) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account confirmed!'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context);
            });
          }

          return Form(
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'Username'),
                  controller: _usernameController,
                ),
                TextFormField(
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                      labelText: 'Confirmation code from email'),
                  controller: _confirmationCodeController,
                  onFieldSubmitted: (value) {
                    submit();
                  },
                ),
                RaisedButton(
                  onPressed: state is! SignUpLoading ? submit : null,
                  child: Text('Confirm Account'),
                ),
                Container(
                  child: state is SignUpLoading
                      ? LoadingIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  @override
  void dispose() {
    _signUpConfirmationBloc.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';
import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  // ignore: close_sinks
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  submit() {
    _loginBloc.add(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  signup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SignUpPage(
                userRepository: _userRepository,
              )),
    );
  }

  signInGoogle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SignInWithGooglePage(
                userRepository: _userRepository,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      backgroundColor: Colors.grey,
      body: BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (
          BuildContext context,
          LoginState state,
        ) {
          if (state is LoginFailure) {
            onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          return Form(
            key: _formKey,
            child: Center(
              child: Container(
                width: 350,
                height: 350,
                child: Card(
                  child: Stack(
                    children: [
                      ListView(
                        padding: EdgeInsets.only(
                            left: 30, right: 30, top: 30, bottom: 10),
                        children: [
                          Container(
                            child: TextFormField(
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                              controller: _usernameController,
                              focusNode: _usernameFocus,
                              onFieldSubmitted: (value) {
                                _usernameFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your username';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.go,
                            decoration: InputDecoration(labelText: 'Password'),
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: true,
                            onFieldSubmitted: (value) {
                              submit();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your password';
                              } else {
                                return null;
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: RaisedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (state is! LoginLoading) {
                                    submit();
                                  }
                                }
                              },
                              child: Text('Login'),
                            ),
                          ),
                          new FlatButton(
                            child: new Text(
                              'Sign Up',
                              style: new TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              signup(context);
                            },
                          ),
//                          new FlatButton(
//                            child: new Text(
//                              'Sign in with Google',
//                              style: new TextStyle(color: Colors.blue),
//                            ),
//                            onPressed: () {
//                              signInGoogle(context);
//                            },
//                          ),
//                          new FlatButton(
//                            child: new Text(
//                              'Sign in with Facebook',
//                              style: new TextStyle(color: Colors.blue),
//                            ),
//                            onPressed: () {},
//                          ),
                        ],
                      ),
                      Container(
                        child:
                            state is LoginLoading ? LoadingIndicator() : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.close();
    super.dispose();
  }
}

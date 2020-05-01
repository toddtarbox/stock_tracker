import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';

class SignUpPage extends StatefulWidget {
  final UserRepository userRepository;

  SignUpPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  AuthenticationBloc _authenticationBloc;
  SignUpBloc _signUpBloc;

  UserRepository get _userRepository => widget.userRepository;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _signUpBloc = SignUpBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  void submit() async {
    _signUpBloc.add(SignUpButtonPressed(
      name: _nameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      backgroundColor: Colors.grey,
      body: BlocBuilder<SignUpBloc, SignUpState>(
        bloc: _signUpBloc,
        builder: (
          BuildContext context,
          SignUpState state,
        ) {
          if (state is SignUpFailure) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          if (state is SignUpSuccess) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thanks for signing up!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ConfirmationPage(
                          userRepository: _userRepository,
                        )),
              );
            });
          }

          return Form(
            key: _formKey,
            child: Center(
              child: Container (
                width: 350,
                height: 500,
                child: Card(
                  child: Stack(
                    children: <Widget>[
                      ListView(
                        padding: EdgeInsets.all(30),
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Name'),
                            controller: _nameController,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              _nameFocus.unfocus();
                              FocusScope.of(context).requestFocus(_emailFocus);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your name';
                              } else {
                                return null;
                              }
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              _emailFocus.unfocus();
                              FocusScope.of(context).requestFocus(_usernameFocus);
                            },
                            validator: validateEmail,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username'),
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              _usernameFocus.unfocus();
                              FocusScope.of(context).requestFocus(_passwordFocus);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a username';
                              } else {
                                return null;
                              }
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            textInputAction: TextInputAction.next,
                            obscureText: true,
                            onFieldSubmitted: (value) {
                              _passwordFocus.unfocus();
                              FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a password';
                              } else {
                                return validatePassword(value, _confirmPasswordController.text);
                              }
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Confirm Password'),
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            textInputAction: TextInputAction.go,
                            obscureText: true,
                            onFieldSubmitted: (value) {
                              submit();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please confirm your password';
                              } else {
                                return validatePassword(_passwordController.text, value);
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: RaisedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (state is! SignUpLoading) {
                                    submit();
                                  }
                                }
                              },
                              child : Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: state is SignUpLoading ? LoadingIndicator() : null,
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

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  @override
  void dispose() {
    _signUpBloc.close();
    super.dispose();
  }
}

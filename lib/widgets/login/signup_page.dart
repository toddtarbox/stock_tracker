import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/utils/utils.dart';
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

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

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
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
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
            child: Padding(
              padding: EdgeInsets.all(50),
              child: Stack(
                children: <Widget>[
                  ListView(
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
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        autovalidate: true,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          _emailFocus.unfocus();
                          FocusScope.of(context).requestFocus(_usernameFocus);
                        },
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
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.go,
                        obscureText: true,
                        onFieldSubmitted: (value) {
                          submit();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(50),
                        child: RaisedButton(
                          onPressed: state is! SignUpLoading ? submit : null,
                          child: Text('Sign Up'),
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

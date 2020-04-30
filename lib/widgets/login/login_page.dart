import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
      new MaterialPageRoute(
          builder: (context) => new SignUpPage(
                userRepository: _userRepository,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocBuilder<LoginBloc, LoginState>(
        bloc: _loginBloc,
        builder: (
          BuildContext context,
          LoginState state,
        ) {
          if (state is LoginFailure) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          return Form(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: Stack(
                children: [
                  ListView(
                    children: [
                      TextFormField(
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: 'Username'),
                        controller: _usernameController,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(labelText: 'Password'),
                        controller: _passwordController,
                        obscureText: true,
                        onFieldSubmitted: (value) {
                          submit();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(50),
                        child: RaisedButton(
                          onPressed: state is! LoginLoading ? submit : null,
                          child: Text('Login'),
                        ),
                      ),
                      new FlatButton(
                        child: new Text(
                          'Sign up',
                          style: new TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          signup(context);
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: state is LoginLoading ? LoadingIndicator() : null,
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
    _loginBloc.close();
    _authenticationBloc.close();
    super.dispose();
  }
}

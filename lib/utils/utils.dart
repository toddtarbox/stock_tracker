import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid email address';
  } else {
    return null;
  }
}

String validatePassword(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'Passwords do not match';
  } else {
    return null;
  }
}

void onWidgetDidBuild(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}

Future<bool> shouldExitApp(BuildContext context) {
  return showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Do you want to exit this application?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: Text('Yes'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> shouldSignOut(BuildContext context) {
  return showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      ) ??
      false;
}

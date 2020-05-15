import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/widgets.dart';

class SignInWithGooglePage extends StatefulWidget {
  final UserRepository userRepository;

  SignInWithGooglePage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  _SignInWithGooglePageState createState() => _SignInWithGooglePageState();
}

class _SignInWithGooglePageState extends State<SignInWithGooglePage> {
  final userAgent =
      'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

  @override
  Widget build(BuildContext context) {
    var url =
        'https://stocktracker.auth.us-east-2.amazoncognito.com/oauth2/authorize' +
            '?identity_provider=Google' +
            '&redirect_uri=stocktracker://' +
            '&response_type=CODE' +
            '&client_id=6gmlbmjd6t57qcvh1s62pvagoj' +
            '&scope=email';

    return Scaffold(
        appBar: CommonAppBar(),
        body: WebView(
          initialUrl: url,
          userAgent: userAgent,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('stocktracker://?code=')) {
              String authCode =
                  request.url.replaceAll('stocktracker://?code=', '');
              widget.userRepository.authenticateWithAuthCode(authCode);
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ));
  }
}

import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Secrets {
  final String iexcloudApiKey;

  Secrets({this.iexcloudApiKey});

  factory Secrets.fromJson(Map<Object, dynamic> jsonMap) {
    return new Secrets(iexcloudApiKey: jsonMap['iexcloudApiKey']);
  }
}

class SecretLoader {
  final String secretPath;

  SecretLoader({this.secretPath});

  Future<Secrets> load() {
    return rootBundle.loadStructuredData<Secrets>(this.secretPath,
        (jsonStr) async {
      final secret = Secrets.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}

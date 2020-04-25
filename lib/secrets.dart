import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class Secrets {
  final String apiKey;

  Secrets({this.apiKey});

  factory Secrets.fromJson(Map<Object, dynamic> jsonMap) {
    return new Secrets(apiKey: jsonMap["apiKey"]);
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

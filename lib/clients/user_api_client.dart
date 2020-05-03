import 'package:meta/meta.dart';
import 'package:http/http.dart';

class UserApiClient {
  final Client httpClient;

  UserApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);
}

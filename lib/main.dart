import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:stocktracker/secrets.dart';

import 'package:stocktracker/simple_block_delegate.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/widgets.dart';

void main() async {
  // Always call this if the main method is asynchronous
  WidgetsFlutterBinding.ensureInitialized();

  // Load the secrets into memory
  Secrets secrets =
      await SecretLoader(secretPath: 'assets/secrets.json').load();

  BlocSupervisor.delegate = SimpleBlocDelegate();

  final StockRepository stockRepository = StockRepository(
    stockApiClient: StockApiClient(
      httpClient: Client(),
      secrets: secrets,
    ),
  );

  final UserRepository userRepository = UserRepository(
    userApiClient: UserApiClient(
      httpClient: Client(),
    ),
  );

  runApp(App(userRepository: userRepository, stockRepository: stockRepository));
}

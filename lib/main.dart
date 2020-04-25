import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import 'package:stocktracker/simple_block_delegate.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/widgets.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final StockRepository stockRepository = StockRepository(
    stockApiClient: StockApiClient(
      httpClient: Client(),
    ),
  );

  runApp(App(stockRepository: stockRepository));
}

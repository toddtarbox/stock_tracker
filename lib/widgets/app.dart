import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/widgets/widgets.dart';

class App extends StatelessWidget {
  final StockRepository stockRepository;

  App({Key key, @required this.stockRepository})
      : assert(stockRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => StockBloc(stockRepository: stockRepository),
        child: Stock(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';

class App extends StatefulWidget {
  final UserRepository userRepository;
  final StockRepository stockRepository;

  App({Key key, @required this.userRepository, @required this.stockRepository})
      : assert(userRepository != null && stockRepository != null),
        super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  ExchangesBloc _exchangesBloc;
  ExchangeSymbolsBloc _exchangeSymbolsBloc;
  StockBloc _stockBloc;

  UserRepository get _userRepository => widget.userRepository;
  StockRepository get _stockRepository => widget.stockRepository;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.add(AppStarted());

    _exchangesBloc = ExchangesBloc(stockRepository: _stockRepository);
    _exchangeSymbolsBloc =
        ExchangeSymbolsBloc(stockRepository: _stockRepository);
    _stockBloc = StockBloc(stockRepository: _stockRepository);

    super.initState();
  }

  @override
  void dispose() {
    _exchangesBloc.close();
    _exchangeSymbolsBloc.close();
    _stockBloc.close();
    _authenticationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => _authenticationBloc,
        ),
        BlocProvider<ExchangesBloc>(
          create: (context) => _exchangesBloc,
        ),
        BlocProvider<ExchangeSymbolsBloc>(
          create: (context) => _exchangeSymbolsBloc,
        ),
        BlocProvider<StockBloc>(
          create: (context) => _stockBloc,
        )
      ],
      child: MaterialApp(
        title: 'Stock Tracker',
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }

            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: _userRepository);
            }

            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }

            if (state is AuthenticationAuthenticated) {
              return MarketSelection();
            }

            return LoadingIndicator();
          },
        ),
      ),
    );
  }
}

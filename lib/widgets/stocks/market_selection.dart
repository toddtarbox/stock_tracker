import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stocktracker/blocs/blocs.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';

class MarketSelection extends StatefulWidget {
  @override
  State<MarketSelection> createState() => _MarketSelectionState();
}

class _MarketSelectionState extends State<MarketSelection> {
  static List<StockMarket> availableMarkets = [
    StockMarket(name: 'Equities', key: 'equities'),
    StockMarket(name: 'Cryptocurrency', key: 'crypto'),
  ];

  StockMarket _selectedMarket = availableMarkets[0];

  final StockExchange _cryptExchange = StockExchange(
      exchange: 'crypto',
      region: '',
      description: 'Crypt Exchange',
      mic: '',
      exchangeSuffix: '');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => shouldExitApp(context),
        child: Scaffold(
            backgroundColor: Colors.grey,
            body: Center(
              child: Container(
                width: 350,
                height: 350,
                child: Card(
                  child: ListView(
                      padding: EdgeInsets.only(
                          left: 30, right: 30, top: 30, bottom: 10),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Select an Market',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: DropdownButton<StockMarket>(
                            items: availableMarkets
                                .map((market) => DropdownMenuItem<StockMarket>(
                                      value: market,
                                      child: Text(market.name),
                                    ))
                                .toList(),
                            value: _selectedMarket,
                            onChanged: (value) {
                              setState(() {
                                _selectedMarket = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              BlocProvider.of<ExchangeSymbolsBloc>(context).add(ClearExchange());
                              if (_selectedMarket.key == 'crypto') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SymbolSelection(
                                          selectedExchange: _cryptExchange)),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ExchangeSelection()),
                                );
                              }
                            },
                            child: Text('Next'),
                          ),
                        ),
                      ]),
                ),
              ),
            )));
  }
}

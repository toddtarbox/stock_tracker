import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';

class SymbolSelection extends StatefulWidget {
  final StockExchange selectedExchange;

  SymbolSelection({this.selectedExchange}) : assert(selectedExchange != null);

  @override
  State<SymbolSelection> createState() => _SymbolSelectionState();
}

class _SymbolSelectionState extends State<SymbolSelection> {
  StockSymbol _selectedSymbol;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          resetToMarketSelection(context);
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.grey,
          body: BlocBuilder<ExchangeSymbolsBloc, ExchangeSymbolsState>(
            builder: (BuildContext context, ExchangeSymbolsState state) {
              if (state is ExchangeSymbolsEmpty) {
                onWidgetDidBuild(() {
                  BlocProvider.of<ExchangeSymbolsBloc>(context).add(
                      FetchExchangeSymbols(
                          exchange: widget.selectedExchange.exchange));
                });
                return LoadingIndicator();
              }

              if (state is ExchangeSymbolsLoading) {
                return LoadingIndicator();
              }

              if (state is ExchangeSymbolsLoaded) {
                return Center(
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
                                'Select a Symbol',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Center(
                              child: SearchableDropdown.single(
                                items: _getDropdownMenuItems(state.symbols),
                                value: _selectedSymbol != null
                                    ? _selectedSymbol
                                    : _selectedSymbol = state.symbols[0],
                                hint: "Select symbol",
                                searchHint: "Search for symbol",
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSymbol = value;
                                  });
                                },
                                isExpanded: true,
                                searchFn: (String keyword, items) {
                                  List<int> ret = List<int>();
                                  if (keyword != null &&
                                      items != null &&
                                      keyword.isNotEmpty) {
                                    keyword.split(" ").forEach((k) {
                                      int i = 0;
                                      items.forEach((item) {
                                        if (k.isNotEmpty &&
                                            (item.value
                                                .toString()
                                                .toLowerCase()
                                                .contains(k.toLowerCase()))) {
                                          ret.add(i);
                                        }
                                        i++;
                                      });
                                    });
                                  }
                                  if (keyword.isEmpty) {
                                    ret = Iterable<int>.generate(items.length)
                                        .toList();
                                  }
                                  return (ret);
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Previous'),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: RaisedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      BlocProvider.of<StockBloc>(context).add(ClearStock());
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Stock(
                                              selectedStockExchange:
                                              widget.selectedExchange,
                                              selectedStockSymbol:
                                              _selectedSymbol,
                                            )),
                                      );
                                    },
                                    child: Text('Next'),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                );
              }

              if (state is ExchangesError) {
                return Center(
                  child: Text(
                    "We're sorry. We were unable to load any exchanges.",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              return LoadingIndicator();
            },
          ),
        ));
  }

  List<DropdownMenuItem> _getDropdownMenuItems(List<StockSymbol> symbols) {
    return symbols
        .map((symbol) => DropdownMenuItem<StockSymbol>(
              value: symbol,
              child: AutoSizeText(
                symbol.displayName,
                maxLines: 2,
              ),
            ))
        .toList();
  }
}

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stocktracker/blocs/blocs.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/widgets/widgets.dart';

class ExchangeSelection extends StatefulWidget {
  @override
  State<ExchangeSelection> createState() => _ExchangeSelectionState();
}

class _ExchangeSelectionState extends State<ExchangeSelection> {
  StockExchange _selectedExchange;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) => {
          if (prefs.containsKey('_selectedExchange'))
            {
              setState(() {
                _selectedExchange = StockExchange.fromPrefsString(
                    prefs.getString('_selectedExchange'));
              })
            }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: BlocBuilder<ExchangesBloc, ExchangesState>(
        builder: (BuildContext context, ExchangesState state) {
          if (state is ExchangesEmpty) {
            onWidgetDidBuild(() {
              BlocProvider.of<ExchangesBloc>(context).add(FetchExchanges());
            });
            return LoadingIndicator();
          }

          if (state is ExchangesLoading) {
            return LoadingIndicator();
          }

          if (state is ExchangesLoaded) {
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
                            'Select an Exchange',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: SearchableDropdown.single(
                            items: _getDropdownMenuItems(state.exchanges),
                            value: _selectedExchange != null
                                ? _selectedExchange
                                : _selectedExchange = state.exchanges[0],
                            hint: "Select exchange",
                            searchHint: "Search for exchange",
                            onChanged: (value) {
                              setState(() {
                                _selectedExchange = value;
                              });
                              SharedPreferences.getInstance().then((prefs) =>
                                  prefs.setString('_selectedExchange',
                                      jsonEncode(_selectedExchange.toJson())));
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
                                  BlocProvider.of<ExchangeSymbolsBloc>(context)
                                      .add(ClearExchange());
                                  Navigator.push(
                                    context,
                                    SlideLeftRoute(
                                        page: SymbolSelection(
                                            selectedExchange:
                                                _selectedExchange)),
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
    );
  }

  List<DropdownMenuItem> _getDropdownMenuItems(List<StockExchange> exchanges) {
    return exchanges
        .map((exchange) => DropdownMenuItem<StockExchange>(
              value: exchange,
              child: AutoSizeText(
                exchange.displayName,
                maxLines: 2,
              ),
            ))
        .toList();
  }
}

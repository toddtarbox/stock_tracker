import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stocktracker/utils/utils.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/widgets/widgets.dart';
import 'package:stocktracker/blocs/blocs.dart';

class Stock extends StatefulWidget {
  final StockExchange selectedStockExchange;
  final StockSymbol selectedStockSymbol;

  Stock({this.selectedStockExchange, this.selectedStockSymbol})
      : assert(selectedStockExchange != null && selectedStockSymbol != null);

  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  Completer<void> _refreshCompleter;

  List<charts.Series<IntraDayEntry, DateTime>> _intraDayChartData;
  List<charts.Series<DayEntry, DateTime>> _historicalChartData;

  IntraDayEntry _selectedIntraDay;
  DayEntry _selectedHistoric;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          resetToMarketSelection(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Stock Tracker'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  resetToMarketSelection(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () async {
                  if (await shouldSignOut(context)) {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedOut());
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              )
            ],
          ),
          body: Center(
            child: BlocConsumer<StockBloc, StockState>(
              listener: (context, state) {
                if (state is StockLoaded) {
                  _refreshCompleter?.complete();
                  _refreshCompleter = Completer();
                }
              },
              builder: (context, state) {
                if (state is StockEmpty) {
                  onWidgetDidBuild(() {
                    BlocProvider.of<StockBloc>(context).add(FetchStock(
                        exchange: widget.selectedStockExchange.exchange,
                        symbol: widget.selectedStockSymbol.symbol));
                  });
                  return LoadingIndicator();
                }

                if (state is StockLoading) {
                  return LoadingIndicator();
                }

                if (state is StockLoaded) {
                  final stockQuote = state.stockQuote;

                  return RefreshIndicator(
                      onRefresh: () {
                        _clearData();
                        BlocProvider.of<StockBloc>(context).add(RefreshStock(
                            exchange: widget.selectedStockExchange.exchange,
                            symbol: state.stockQuote.symbol));
                        return _refreshCompleter.future;
                      },
                      child: MediaQuery.of(context).size.width < 600
                          ? _renderPortrait(context, stockQuote)
                          : _renderLandscape(context, stockQuote));
                }

                if (state is StockError) {
                  return Text(
                    "We're sorry. We could not find that symbol.",
                    style: TextStyle(color: Colors.red),
                  );
                }

                return null;
              },
            ),
          ),
        ));
  }

  Widget _renderPortrait(BuildContext context, StockQuote stockQuote) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: AutoSizeText(
                    stockQuote.displayName,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 25.0),
              child: Center(
                child: _renderQuote(context, stockQuote),
              ),
            ),
            _renderStats(context, stockQuote),
            _renderIntraDayChart(context, stockQuote),
            _renderHistoricChart(context, stockQuote),
            _renderNews(context, stockQuote),
          ],
        ),
      ),
    );
  }

  Widget _renderLandscape(BuildContext context, StockQuote stockQuote) {
    return ListView(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * .35,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    child: Center(
                      child: AutoSizeText(
                        stockQuote.displayName,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _renderQuote(context, stockQuote),
                  ),
                  _renderStats(context, stockQuote),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .50,
              child: Column(
                children: <Widget>[
                  _renderIntraDayChart(context, stockQuote),
                  _renderHistoricChart(context, stockQuote),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: _renderNews(context, stockQuote),
            ),
          ],
        ),
      ],
    );
  }

  Widget _renderQuote(BuildContext context, StockQuote stockQuote) {
    return Text(stockQuote.getChangeText,
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: stockQuote.isPositiveChange() ? Colors.green : Colors.red));
  }

  Widget _renderStats(BuildContext context, StockQuote stockQuote) {
    if (widget.selectedStockExchange.exchange == 'crypto') {
      return Container();
    }
    return Row(
      children: <Widget>[
        Card(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('Open:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(stockQuote.open.toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('High:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(NumberFormat.compact()
                            .format(stockQuote.high)
                            .toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('Low:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(NumberFormat.compact()
                            .format(stockQuote.low)
                            .toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('52 WK High:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(stockQuote.fiftyTwoWeekHigh.toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('52 WK Low:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(stockQuote.fiftyTwoWeekLow.toString())),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('Volume:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(stockQuote.latestVolume != null
                            ? NumberFormat.compact()
                                .format(stockQuote.latestVolume)
                                .toString()
                            : '')),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('Avg Volume:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(NumberFormat.compact()
                            .format(stockQuote.averageVolume)
                            .toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('Market Cap:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(NumberFormat.compact()
                            .format(stockQuote.marketCap)
                            .toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Text('P/E Ratio:')),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(stockQuote.peRatio.toString())),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(8), child: Text('')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderIntraDayChart(BuildContext context, StockQuote stockQuote) {
    if (stockQuote.stockIntraDay.intraDayEntries.length == 0) {
      return Container();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              'Intra Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: charts.TimeSeriesChart(
                _getIntraDayChartData(stockQuote),
                behaviors: [
                  charts.PanAndZoomBehavior(),
                ],
                selectionModels: [
                  charts.SelectionModelConfig(
                      changedListener: (charts.SelectionModel model) {
                    if (model.hasDatumSelection) {
                      setState(() {
                        _selectedIntraDay = model.selectedDatum[0].datum;
                      });
                    }
                  }),
                ],
                domainAxis: charts.DateTimeAxisSpec(
                  tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                    minute: charts.TimeFormatterSpec(
                      format: 'mm',
                      transitionFormat: 'h mm a',
                    ),
                  ),
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                    tickProviderSpec:
                        charts.BasicNumericTickProviderSpec(zeroBound: false)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                _selectedIntraDay != null ? _selectedIntraDay.toString() : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderHistoricChart(BuildContext context, StockQuote stockQuote) {
    if (stockQuote.stockHistoric.dailyEntries.length == 0) {
      return Container();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Text(
            'Historic (3 Month)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: charts.TimeSeriesChart(
              _getHistoricalChartData(stockQuote),
              behaviors: [charts.PanAndZoomBehavior()],
              selectionModels: [
                charts.SelectionModelConfig(
                    changedListener: (charts.SelectionModel model) {
                      if (model.hasDatumSelection) {
                        setState(() {
                          _selectedHistoric= model.selectedDatum[0].datum;
                        });
                      }
                    }),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              _selectedHistoric != null ? _selectedHistoric.toString() : '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _renderNews(BuildContext context, StockQuote stockQuote) {
    if (stockQuote.stockNews.newsEntries.length == 0) {
      return Container();
    }

    List<Widget> widgets = [
      Text(
        'Recent News',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    ];
    widgets += _getStockNewsData(stockQuote)
        .map((newsEntry) => Padding(
            padding: EdgeInsets.all(10),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: newsEntry.headline +
                        '\n' +
                        '(Source: ${newsEntry.source})',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(newsEntry.link);
                      }))))
        .toList();
    return Card(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: widgets,
            )));
  }

  List<charts.Series<IntraDayEntry, DateTime>> _getIntraDayChartData(
      StockQuote stockQuote) {
    if (_intraDayChartData != null) {
      return _intraDayChartData;
    }

    _intraDayChartData = List<charts.Series<IntraDayEntry, DateTime>>();

    _intraDayChartData.add(
      charts.Series(
        domainFn: (IntraDayEntry entry, _) => entry.date,
        measureFn: (IntraDayEntry entry, _) => entry.close,
        id: 'Day Chart',
        data: stockQuote.stockIntraDay.intraDayEntries,
      ),
    );

    return _intraDayChartData;
  }

  List<charts.Series<DayEntry, DateTime>> _getHistoricalChartData(
      StockQuote stockQuote) {
    if (_historicalChartData != null) {
      return _historicalChartData;
    }

    _historicalChartData = List<charts.Series<DayEntry, DateTime>>();

    if (stockQuote.stockHistoric != null) {
      _historicalChartData.add(
        charts.Series(
          domainFn: (DayEntry entry, _) => entry.date,
          measureFn: (DayEntry entry, _) => entry.close,
          id: 'Historic Chart',
          data: stockQuote.stockHistoric.dailyEntries,
        ),
      );
    }

    return _historicalChartData;
  }

  List<NewsEntry> _getStockNewsData(StockQuote stockQuote) {
    if (stockQuote.stockNews != null) {
      return stockQuote.stockNews.newsEntries;
    } else {
      return null;
    }
  }

  void _clearData() {
    _selectedIntraDay = null;
    _selectedHistoric = null;
    _intraDayChartData = null;
  }
}

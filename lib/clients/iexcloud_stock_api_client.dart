import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:stocktracker/clients/base_stock_api_client.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/models/stock_historic.dart';
import 'package:stocktracker/secrets.dart';

class IEXCloudStockApiClient implements StockApiClient {
  static const String baseExchangesUrl =
      'https://cloud.iexapis.com/v1/ref-data/exchanges?token=';
  static const String baseExchangeSymbolsUrl =
      'https://cloud.iexapis.com/v1/ref-data/exchange/[exchange]/symbols?token=';
  static const String baseQuotelUrl =
      'https://cloud.iexapis.com/v1/stock/[symbol]/quote?token=';
  static const String baseIntraDayUrl =
      'https://cloud.iexapis.com/v1/stock/[symbol]/intraday-prices?range=3m&token=';
  static const String baseHistoricUrl =
      'https://cloud.iexapis.com/v1/stock/[symbol]/chart/3m?chartCloseOnly=true&chartByDay=true&token=';
  static const String baseNewsUrl =
      'https://cloud.iexapis.com/v1/stock/[symbol]/news/last/5?token=';

  static const String baseCryptSymbolsUrl =
      'https://cloud.iexapis.com/v1/ref-data/crypto/symbols?token=';
  static const String baseCryptQuoteUrl =
      'https://cloud.iexapis.com/v1/crypto/[symbol]/quote?token=';

  final Client httpClient;

  final Secrets secrets;

  IEXCloudStockApiClient({
    @required this.httpClient,
    @required this.secrets,
  }) : assert(httpClient != null && secrets != null);

  @override
  Future<List<StockExchange>> fetchExchanges() async {
    final quoteUrl = baseExchangesUrl + secrets.iexcloudApiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting exchanges');
    }

    final exchangesJson = jsonDecode(response.body);
    return StockExchange.listFromIEXCloudJson(exchangesJson);
  }

  @override
  Future<List<StockSymbol>> fetchExchangeSymbols(String exchange) async {
    String quoteUrl =
        baseExchangeSymbolsUrl.replaceAll('[exchange]', exchange) +
            secrets.iexcloudApiKey;
    if (exchange == 'crypto') {
      quoteUrl = baseCryptSymbolsUrl + secrets.iexcloudApiKey;
    }
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting symbols for exchange: ' + exchange);
    }

    final symbolsJson = jsonDecode(response.body);
    return StockSymbol.listFromIEXCloudJson(symbolsJson);
  }

  @override
  Future<StockQuote> fetchStock(String exchange, String symbol) async {
    String quoteUrl =
        baseQuotelUrl.replaceAll('[symbol]', symbol) + secrets.iexcloudApiKey;
    if (exchange == 'crypto') {
      quoteUrl = baseCryptQuoteUrl.replaceAll('[symbol]', symbol) +
          secrets.iexcloudApiKey;
    }
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting stock quote for symbol: ' + symbol);
    }

    final quoteJson = jsonDecode(response.body);
    return StockQuote.fromIEXCloudJson(quoteJson);
  }

  @override
  Future<StockIntraDay> fetchStockIntraDay(String symbol) async {
    final quoteUrl =
        baseIntraDayUrl.replaceAll('[symbol]', symbol) + secrets.iexcloudApiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception(
          'Error getting intraday stock prices for symbol: ' + symbol);
    }

    final dayJson = jsonDecode(response.body);
    return StockIntraDay.fromIEXCloudJson(dayJson);
  }

  @override
  Future<StockHistoric> fetchStockHistoric(String symbol) async {
    final quoteUrl =
        baseHistoricUrl.replaceAll('[symbol]', symbol) + secrets.iexcloudApiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception(
          'Error getting stock historic prices for symbol: ' + symbol);
    }

    final dayJson = jsonDecode(response.body);
    return StockHistoric.fromIEXCloudJson(dayJson);
  }

  @override
  Future<StockNews> fetchStockNews(String symbol) async {
    final quoteUrl =
        baseNewsUrl.replaceAll('[symbol]', symbol) + secrets.iexcloudApiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting stock news for symbol: ' + symbol);
    }

    final newsJson = jsonDecode(response.body);
    return StockNews.fromIEXCloudJson(newsJson);
  }
}

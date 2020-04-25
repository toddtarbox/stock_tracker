import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/models/stock_historic.dart';
import 'package:stocktracker/secrets.dart';

class StockApiClient {
  static const String baseBatchUrl =
      'https://cloud.iexapis.com/stable/stock/%s/batch?&types=quote,intraday-prices&range=3m&token=';
  static const String baseHistoricUrl =
      'https://cloud.iexapis.com/stable/stock/%s/chart/3m?token=';

  final Client httpClient;

  final Secrets secrets;

  StockApiClient({
    @required this.httpClient,
    @required this.secrets,
  }) : assert(httpClient != null && secrets != null);

  Future<StockQuote> fetchStock(String symbol) async {
    final quoteUrl = baseBatchUrl.replaceAll('%s', symbol) + secrets.apiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting stock quote for symbol: ' + symbol);
    }

    final quoteJson = jsonDecode(response.body);
    return StockQuote.fromJson(quoteJson);
  }

  Future<StockHistoric> fetchStockHistoric(String symbol) async {
    final quoteUrl = baseHistoricUrl.replaceAll('%s', symbol) + secrets.apiKey;
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception(
          'Error getting stock historic prices for symbol: ' + symbol);
    }

    final dayJson = jsonDecode(response.body);
    return StockHistoric.fromJson(dayJson);
  }
}

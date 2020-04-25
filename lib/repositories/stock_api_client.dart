import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart';

import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/models/stock_historic.dart';
import 'package:stocktracker/secrets.dart';

class StockApiClient {
  String baseBatchUrl =
      'https://cloud.iexapis.com/stable/stock/%s/batch?&types=quote,intraday-prices&range=3m&token=API_KEY';
  String baseHistoricUrl =
      'https://cloud.iexapis.com/stable/stock/%s/chart/3m?token=API_KEY';

  final Client httpClient;

  Secrets secrets;

  StockApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);

  Future<void> _init() async {
    if (secrets == null) {
      secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();

      baseBatchUrl = baseBatchUrl.replaceAll('API_KEY', secrets.apiKey);
      baseHistoricUrl = baseHistoricUrl.replaceAll('API_KEY', secrets.apiKey);
    }
  }

  Future<StockQuote> fetchStock(String symbol) async {
    await _init();

    final quoteUrl = baseBatchUrl.replaceAll('%s', symbol);
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception('Error getting stock quote for symbol: ' + symbol);
    }

    final quoteJson = jsonDecode(response.body);
    return StockQuote.fromJson(quoteJson);
  }

  Future<StockHistoric> fetchStockHistoric(String symbol) async {
    await _init();

    final quoteUrl = baseHistoricUrl.replaceAll('%s', symbol);
    final response = await httpClient.get(quoteUrl);

    if (response.statusCode != 200) {
      throw Exception(
          'Error getting stock historic prices for symbol: ' + symbol);
    }

    final dayJson = jsonDecode(response.body);
    return StockHistoric.fromJson(dayJson);
  }
}

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/blocs/blocs.dart';

class ExchangeSymbolsBloc
    extends Bloc<ExchangeSymbolsEvent, ExchangeSymbolsState> {
  final StockRepository stockRepository;

  ExchangeSymbolsBloc({@required this.stockRepository})
      : assert(stockRepository != null);

  @override
  ExchangeSymbolsState get initialState => ExchangeSymbolsEmpty();

  @override
  Stream<ExchangeSymbolsState> mapEventToState(
      ExchangeSymbolsEvent event) async* {
    if (event is ClearExchange) {
      yield ExchangeSymbolsEmpty();
    }

    if (event is FetchExchangeSymbols) {
      yield ExchangeSymbolsLoading();
      try {
        final List<StockSymbol> symbols =
            await stockRepository.getExchangeSymbols(event.exchange);
        yield ExchangeSymbolsLoaded(symbols: symbols);
      } catch (error) {
        yield ExchangeSymbolsError(error: error.toString());
      }
    }
  }
}

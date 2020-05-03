import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:stocktracker/repositories/repositories.dart';
import 'package:stocktracker/models/models.dart';
import 'package:stocktracker/blocs/blocs.dart';

class ExchangesBloc extends Bloc<ExchangesEvent, ExchangesState> {
  final StockRepository stockRepository;

  ExchangesBloc({@required this.stockRepository})
      : assert(stockRepository != null);

  @override
  ExchangesState get initialState => ExchangesEmpty();

  @override
  Stream<ExchangesState> mapEventToState(ExchangesEvent event) async* {
    if (event is FetchExchanges) {
      yield ExchangesLoading();
      try {
        final List<StockExchange> exchanges =
            await stockRepository.getExchanges();
        yield ExchangesLoaded(exchanges: exchanges);
      } catch (error) {
        yield ExchangesError(error: error.toString());
      }
    }
  }
}

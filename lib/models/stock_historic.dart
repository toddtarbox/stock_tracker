import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class DayEntry extends Equatable {
  final DateTime date;
  final double close;

  const DayEntry({this.date, this.close});

  @override
  List<Object> get props => [
        date,
        close,
      ];

  static DayEntry fromIEXCloudJson(dynamic json) {
    final String date = json['date'];
    final DateTime dateTime = DateTime.parse(date);

    var close = json['close'];
    if (close == null) {
      return null;
    }

    return DayEntry(date: dateTime, close: close.toDouble());
  }

  @override
  String toString() {
    var formatter = new DateFormat('MM-dd-yyyy');
    return formatter.format(date.toLocal()) + " " + close.toString();
  }
}

class StockHistoric extends Equatable {
  final List<DayEntry> dailyEntries = List<DayEntry>();

  StockHistoric();

  @override
  List<Object> get props => [dailyEntries];

  static StockHistoric fromIEXCloudJson(dynamic json) {
    StockHistoric stockHistoric = StockHistoric();
    for (dynamic entry in json) {
      DayEntry dayEntry = DayEntry.fromIEXCloudJson(entry);
      if (dayEntry != null) {
        stockHistoric.dailyEntries.add(dayEntry);
      }
    }

    return stockHistoric;
  }
}

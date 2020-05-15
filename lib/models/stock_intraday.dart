import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class IntraDayEntry extends Equatable {
  final DateTime date;
  final String label;
  final double close;

  const IntraDayEntry({this.date, this.label, this.close});

  @override
  List<Object> get props => [
        date,
        label,
        close,
      ];

  static IntraDayEntry fromIEXCloudJson(dynamic json) {
    final String date = json['date'];
    final String time = json['minute'];
    final DateTime dateTime = DateTime.parse(date + ' ' + time);

    final label = json['label'];

    var close = json['close'];
    if (close == null) {
      return null;
    }

    return IntraDayEntry(date: dateTime, label: label, close: close.toDouble());
  }

  @override
  String toString() {
    var formatter = new DateFormat('MM-dd-yyyy HH:mm a');
    return formatter.format(date.toLocal()) + " " + close.toString();
  }
}

class StockIntraDay extends Equatable {
  final List<IntraDayEntry> intraDayEntries = List<IntraDayEntry>();

  StockIntraDay();

  @override
  List<Object> get props => [intraDayEntries];

  static StockIntraDay fromIEXCloudJson(dynamic json) {
    StockIntraDay stockIntraDay = StockIntraDay();
    for (dynamic entry in json) {
      IntraDayEntry intraDayEntry = IntraDayEntry.fromIEXCloudJson(entry);
      if (intraDayEntry != null) {
        stockIntraDay.intraDayEntries.add(intraDayEntry);
      }
    }

    return stockIntraDay;
  }
}

import 'package:intl/intl.dart';

class AppFormatters {
  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static String currency(num value) => _currency.format(value);

  static String percent(num value) => '${value.toStringAsFixed(2)}%';

  static String date(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    return _date.format(DateTime.tryParse(raw)?.toLocal() ?? DateTime.now());
  }

  static String dateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    return _dateTime
        .format(DateTime.tryParse(raw)?.toLocal() ?? DateTime.now());
  }
}

import 'package:intl/intl.dart';

abstract final class CurrencyUtils {
  static final format = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs');
}

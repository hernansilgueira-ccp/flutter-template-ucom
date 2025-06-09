import 'package:intl/intl.dart';

class UtilesApp {
  static String formatearFechaDdMMAaaa(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/"
           "${fecha.month.toString().padLeft(2, '0')}/"
           "${fecha.year}";
  }

  static String formatearHoraHHmm(DateTime fecha) {
    final formato = DateFormat('HH:mm');
    return formato.format(fecha);
  }
  static String formatearGuaranies(num monto) {
    final formatter = NumberFormat.currency(
      locale: 'es_PY',
      symbol: '₲',
      decimalDigits: 0,
    );
    return formatter.format(monto);
  }
}

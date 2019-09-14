import 'package:intl/intl.dart';

class NumberUtil {
  /// Converte string para inteiro
  static int toInt(String value) {
    if (value.isEmpty || value.contains(",") || value.contains(".")) {
      return 0;
    }
    return int.parse(value);
  }

  /// Converte string para double
  static double toDouble(String value, {int scale = 0}) {
    value = _validateDecimal(value);
    if (scale > 0) {
      return double.parse(double.parse(value).toStringAsFixed(2));
    }
    return double.parse(value);
  }

  /// Converte string para double
  static double toDoubleFromDouble(double value, {int scale = 0}) {
    if (scale > 0) {
      return double.parse(double.parse(value.toString()).toStringAsFixed(scale));
    }
    return double.parse(value.toString());
  }

  /// Formata para moeda corrente
  static String toFormatCurrency(double value) {
    return NumberFormat.currency().format(value);
  }

  ///Formata casas decimais do brasil
  static String toFormatBr(double value) {
    return NumberFormat("#,##0.00", "pt_BR").format(value);
  }

  ///Formata casas decimais do brasil
  static String toDoubleFormatBr(double value) {
    return NumberFormat("#,##0.00", "pt_BR").format(value);
  }

  //validação de mascara
  static String _validateDecimal(String value) {
    if (value == null || value.isEmpty) {
      return "0";
    }
    if (value.contains(",")) {
      value = value.replaceAll(".", "");
      value = value.replaceAll(",", ".");
    }
    return value;
  }
}

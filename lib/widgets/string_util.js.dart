class StringUtil {
  static String formatarTelefone(String text) {
    final buffer = StringBuffer();
    int length = text.length;
    if (length == 9) {
      buffer.write(text.substring(0, 5));
      buffer.write(" ");
      buffer.write(text.substring(5, 9));
    }
    else if (length == 10) {
      buffer.write("(");
      buffer.write(text.substring(0, 2));
      buffer.write(") ");
      buffer.write(text.substring(2, 6));
      buffer.write("-");
      buffer.write(text.substring(6, 10));
    }
    else if (length == 11) {
      buffer.write("(");
      buffer.write(text.substring(0, 2));
      buffer.write(") ");
      buffer.write(text.substring(2, 7));
      buffer.write("-");
      buffer.write(text.substring(7, 11));
    } else {
      return text;
    }
    return buffer.toString();
  }
}
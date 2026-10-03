class IdUtils {
  IdUtils._();

  static int _counter = 0;

  static String next(String prefix) {
    _counter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}

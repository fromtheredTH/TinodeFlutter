import 'package:logger/logger.dart';

class PrettyLogger {
  static PrettyLogger shared = PrettyLogger._();
  final _logger = Logger(
    printer: PrettyPrinter(
        methodCount: 3, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: true // Should each log print contain a timestamp
        ),
  );

  PrettyLogger._();

  void _log(Level level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) {
    _logger.log(level, message, error, stackTrace);
  }

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.debug, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.error, message, error, stackTrace);
  }

  /// Log a message at level [Level.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log(Level.wtf, message, error, stackTrace);
  }
}

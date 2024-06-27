import '../../../tinode/src/services/configuration.dart';
import 'package:get_it/get_it.dart';
import '../../../tinode/src/utils/pretty_logger.dart';

class LoggerService {
  late ConfigService _configService;

  LoggerService() {
    _configService = GetIt.I.get<ConfigService>();
  }

  void error(String value) {
    if (_configService.loggerEnabled == true) {
      PrettyLogger.shared.e('ERROR: ' + value);
    }
  }

  void log(String value) {
    if (_configService.loggerEnabled == true) {
      PrettyLogger.shared.i('LOG: ' + value);
    }
  }

  void warn(String value) {
    if (_configService.loggerEnabled == true) {
      PrettyLogger.shared.w('WARN: ' + value);
    }
  }
}

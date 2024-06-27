import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../../tinode/src/models/future-callback.dart';
import '../../../tinode/src/services/configuration.dart';

class FutureManager {
  final Map<String, FutureCallback> _pendingFutures = {};
  Timer? _expiredFuturesCheckerTimer;
  late ConfigService _configService;
  final _logger = Logger();

  FutureManager() {
    _configService = GetIt.I.get<ConfigService>();
  }

  Future<dynamic> makeFuture(String id) {
    var completer = Completer();
    if (id.isNotEmpty) {
      _pendingFutures[id] =
          FutureCallback(completer: completer, ts: DateTime.now());
    }
    return completer.future;
  }

  void execFuture(String? id, int code, dynamic onOK, String? errorText) {
    var callbacks = _pendingFutures[id];

    if (callbacks != null) {
      _pendingFutures.remove(id);
      if (code >= 200 && code < 400) {
        callbacks.completer?.complete(onOK);
      } else {
        final exceptionMessage =
            (errorText ?? '') + ' (' + code.toString() + ')';
        callbacks.completer?.completeError(Exception(exceptionMessage));
      }
    }
  }

  void checkExpiredFutures() {
    var exception = Exception('Timeout (504)');
    var expires = DateTime.now().subtract(Duration(
        milliseconds: _configService.appSettings.expireFuturesTimeout));

    var markForRemoval = <String>[];
    _pendingFutures.forEach((String key, FutureCallback featureCB) {
      if (featureCB.ts!.isBefore(expires)) {
        markForRemoval.add(key);
        featureCB.completer?.completeError(exception);
      }
    });
    if (markForRemoval.isNotEmpty) {
      _pendingFutures.removeWhere((key, value) {
        return markForRemoval.contains(key);
      });
    }
  }

  void startCheckingExpiredFutures() {
    if (_expiredFuturesCheckerTimer != null &&
        _expiredFuturesCheckerTimer!.isActive) {
      return;
    }
    final expireFuturesPeriod = _configService.appSettings.expireFuturesPeriod;
    _expiredFuturesCheckerTimer =
        Timer.periodic(Duration(milliseconds: expireFuturesPeriod), (_) {
      checkExpiredFutures();
    });
  }

  void rejectAllFutures(int code, String reason) {
    _pendingFutures.forEach((String key, FutureCallback cb) {
      cb.completer?.completeError(reason);
    });
    _pendingFutures.clear();
  }

  void stopCheckingExpiredFutures() {
    if (_expiredFuturesCheckerTimer != null) {
      _expiredFuturesCheckerTimer?.cancel();
      _expiredFuturesCheckerTimer = null;
    }
  }

  void clear() {
    _pendingFutures.clear();
  }
}

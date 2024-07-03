import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../../../tinode/src/models/server-messages.dart';
import '../../../tinode/src/models/auth-token.dart';
import '../../../tinode/src/services/logger.dart';

class AuthService {
  String? _userId;
  String? _lastLogin;
  AuthToken? _authToken;
  bool _authenticated = false;

  final LoggerService _loggerService = GetIt.I.get<LoggerService>();

  PublishSubject<OnLoginData> onLogin = PublishSubject<OnLoginData>();

  bool get isAuthenticated {
    return _authenticated;
  }

  AuthToken? get authToken {
    return _authToken;
  }

  String? get userId {
    return _userId;
  }

  String? get lastLogin {
    return _lastLogin;
  }

  void setLastLogin(String lastLogin) {
    _lastLogin = lastLogin;
  }

  void setAuthToken(AuthToken authToken) {
    _authToken = authToken;
  }

  void setUserId(String? userId) {
    _userId = userId;
  }

  void reset() {
    _userId = '';
    _lastLogin = '';
    _authToken = null;
    _authenticated = false;
    _loggerService.log(
        'TinodeService#isAuthenticated#AuthService# reset user_id: $_userId');
  }

  void disauthenticate() {
    _authToken = null;
    _authenticated = false;
    _loggerService.log('Tinode chat#AuthService# disauthenticate');
  }

  void onLoginSuccessful(CtrlMessage? ctrl) {
    if (ctrl == null) {
      return;
    }

    var params = ctrl.params;
    if (params == null || params['user'] == null) {
      return;
    }

    _userId = params['user'];
    _authenticated = (ctrl.code ?? 0) >= 200 && (ctrl.code ?? 0) < 300;

    if (params['token'] != null && params['expires'] != null) {

      _authToken =
          AuthToken(params['token'], Uri.encodeComponent(params['token']), DateTime.parse(params['expires']));
    } else {
      _authToken = null;
    }

    var code = ctrl.code;
    var text = ctrl.text;
    if (code != null && text != null) {
      onLogin.add(OnLoginData(code, text));
    }
  }
}

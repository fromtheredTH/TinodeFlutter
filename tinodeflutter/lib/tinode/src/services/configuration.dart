import 'dart:io' show Platform;

import '../../../tinode/src/models/server-configuration.dart';
import '../../../tinode/src/models/app-settings.dart';

class ConfigService {
  late ServerConfiguration _serverConfiguration;
  late AppSettings _appSettings;
  String? humanLanguage;
  String? deviceToken;
  bool? loggerEnabled;
  String appVersion = '';
  String appName = '';

  ConfigService(bool loggerEnabled,
      {required String versionApp,
      required String deviceLocale,
      int? futuresPeriod,
      int? expireFuturesTimeout}) {
    _appSettings = AppSettings(
        0xFFFFFFF, 503, futuresPeriod ?? 1000, expireFuturesTimeout ?? 5000);
    deviceToken = null;
    appVersion = versionApp;
    humanLanguage = deviceLocale;
    this.loggerEnabled = loggerEnabled;
  }

  AppSettings get appSettings {
    return _appSettings;
  }

  ServerConfiguration get serverConfiguration {
    return _serverConfiguration;
  }

  String get userAgent {
    return appName +
        ' (Dart; ' +
        Platform.operatingSystem +
        '); tinode-dart/' +
        appVersion;
  }

  String get platform {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'MacOS';
    } else if (Platform.isWindows) {
      return 'Window';
    } else {
      return 'Unknown';
    }
  }

  void setServerConfiguration(Map<String, dynamic> configuration) {
    _serverConfiguration = ServerConfiguration(
      build: configuration['build'],
      maxFileUploadSize: configuration['maxFileUploadSize'],
      maxMessageSize: configuration['maxMessageSize'],
      maxSubscriberCount: configuration['maxSubscriberCount'],
      maxTagCount: configuration['maxTagCount'],
      maxTagLength: configuration['maxTagLength'],
      minTagLength: configuration['minTagLength'],
      ver: configuration['ver'],
    );
  }
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'softposafs_plugin_method_channel.dart';

abstract class SoftposafsPluginPlatform extends PlatformInterface {
  /// Constructs a SoftposafsPluginPlatform.
  SoftposafsPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SoftposafsPluginPlatform _instance = MethodChannelSoftposafsPlugin();

  /// The default instance of [SoftposafsPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSoftposafsPlugin].
  static SoftposafsPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SoftposafsPluginPlatform] when
  /// they register themselves.
  static set instance(SoftposafsPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> initializeSDK(String strUrl) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> checkPOSService() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> registerDevice(
      String strmerchantId, String strterminalId, String stractivationCode) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> unregisterDevice() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> startTransaction(int transactionId, int amount) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

import 'softposafs_plugin_method_channel.dart';
import 'softposafs_plugin_platform_interface.dart';

class SoftposafsPlugin {
  Future<String?> getPlatformVersion() {
    return SoftposafsPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> initializeSDK(String strUrl) {
    return SoftposafsPluginPlatform.instance.initializeSDK(strUrl);
  }

  Future<String?> checkPOSService() {
    return SoftposafsPluginPlatform.instance.checkPOSService();
  }

  Future<String?> registerDevice(
      String strmerchantId, String strterminalId, String stractivationCode) {
    return SoftposafsPluginPlatform.instance
        .registerDevice(strmerchantId, strterminalId, stractivationCode);
  }

  Future<String?> unregisterDevice() {
    return SoftposafsPluginPlatform.instance.unregisterDevice();
  }

  Future<String?> startTransaction(int transactionId, double amount) {
    return SoftposafsPluginPlatform.instance
        .startTransaction(transactionId, amount);
  }

  /// Expose native event stream
  Stream<String> get onNativeEvent =>
      MethodChannelSoftposafsPlugin.nativeEventStream;
}

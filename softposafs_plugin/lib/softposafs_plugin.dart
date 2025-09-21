import 'softposafs_plugin_method_channel.dart';
import 'softposafs_plugin_platform_interface.dart';

class SoftposafsPlugin {
  Future<String?> getPlatformVersion() {
    return SoftposafsPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> initializeSDK() {
    return SoftposafsPluginPlatform.instance.initializeSDK();
  }

  Future<String?> checkPOSService() {
    return SoftposafsPluginPlatform.instance.checkPOSService();
  }

  Future<String?> registerDevice() {
    return SoftposafsPluginPlatform.instance.registerDevice();
  }

  Future<String?> unregisterDevice() {
    return SoftposafsPluginPlatform.instance.unregisterDevice();
  }

  Future<String?> startTransaction() {
    return SoftposafsPluginPlatform.instance.startTransaction();
  }

  /// Expose native event stream
  Stream<String> get onNativeEvent =>
      MethodChannelSoftposafsPlugin.nativeEventStream;
}

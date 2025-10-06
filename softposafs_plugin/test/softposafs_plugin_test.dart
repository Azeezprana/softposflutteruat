import 'package:flutter_test/flutter_test.dart';
import 'package:softposafs_plugin/softposafs_plugin.dart';
import 'package:softposafs_plugin/softposafs_plugin_platform_interface.dart';
import 'package:softposafs_plugin/softposafs_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSoftposafsPluginPlatform
    with MockPlatformInterfaceMixin
    implements SoftposafsPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> checkPOSService() {
    // TODO: implement checkPOSService
    throw UnimplementedError();
  }

  @override
  Future<String?> initializeSDK(String strUrl) {
    // TODO: implement initializeSDK
    throw UnimplementedError();
  }

  @override
  Future<String?> registerDevice(
      String strmerchantId, String strterminalId, String stractivationCode) {
    // TODO: implement registerDevice
    throw UnimplementedError();
  }

  @override
  Future<String?> startTransaction(int transactionId, double amount) {
    // TODO: implement startTransaction
    throw UnimplementedError();
  }

  @override
  Future<String?> unregisterDevice() {
    // TODO: implement unregisterDevice
    throw UnimplementedError();
  }
}

void main() {
  final SoftposafsPluginPlatform initialPlatform =
      SoftposafsPluginPlatform.instance;

  test('$MethodChannelSoftposafsPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSoftposafsPlugin>());
  });

  test('getPlatformVersion', () async {
    SoftposafsPlugin softposafsPlugin = SoftposafsPlugin();
    MockSoftposafsPluginPlatform fakePlatform = MockSoftposafsPluginPlatform();
    SoftposafsPluginPlatform.instance = fakePlatform;

    expect(await softposafsPlugin.getPlatformVersion(), '42');
  });
}

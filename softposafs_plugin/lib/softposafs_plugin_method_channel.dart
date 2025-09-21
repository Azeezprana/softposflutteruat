import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'softposafs_plugin_platform_interface.dart';

/// An implementation of [SoftposafsPluginPlatform] that uses method channels.
class MethodChannelSoftposafsPlugin extends SoftposafsPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('softposafs_plugin');

  /// Event channel to receive real-time status/logs from native SDK
  static const EventChannel _eventChannel =
      EventChannel('softposafs_plugin_events'); // ✅ MATCHES ANDROID

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<String?> initializeSDK() async {
    try {
      return await methodChannel.invokeMethod<String>('initializeSDK');
    } on PlatformException catch (e) {
      return "SDK initialization failed: ${e.message}";
    }
  }

  Future<String?> checkPOSService() async {
    try {
      return await methodChannel.invokeMethod<String>('checkPOSService');
    } on PlatformException catch (e) {
      return "POS service check failed: ${e.message}";
    }
  }

  Future<String?> registerDevice() async {
    try {
      return await methodChannel.invokeMethod<String>('registerDevice');
    } on PlatformException catch (e) {
      return "Device registration failed: ${e.message}";
    }
  }

  Future<String?> unregisterDevice() async {
    try {
      return await methodChannel.invokeMethod<String>('unregisterDevice');
    } on PlatformException catch (e) {
      return "Device unregistration failed: ${e.message}";
    }
  }

  Future<String?> startTransaction() async {
    try {
      return await methodChannel.invokeMethod<String>('startTransaction');
    } on PlatformException catch (e) {
      return "Transaction start failed: ${e.message}";
    }
  }

  /// Expose broadcast stream for native events (real-time status updates for UI)
  static Stream<String> get nativeEventStream {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .asBroadcastStream(); // allows multiple listeners to subscribe
  }
}

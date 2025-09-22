import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:softposafs_plugin/softposafs_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _softposafsPlugin = SoftposafsPlugin();

  String _status = 'Initializing...';

  late StreamSubscription<String> _eventSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    // ✅ Listen to real-time events from native SDK via EventChannel
    _eventSubscription = _softposafsPlugin.onNativeEvent.listen(
      (event) {
        if (mounted) {
          setState(() {
            _status = event;
            if (_status.isNotEmpty && _status.contains("Permissions needed")) {
              print('Permission required');
              return;
            }
            // else if (_status.isNotEmpty &&
            //     _status.contains("POS is ready.")) {
            //   _checkService().then((value) => null);
            // } else if (_status.isNotEmpty &&
            //     _status.contains("Device registration required")) {
            //   _registerDevice().then((value) => null);
            //   _checkService().then((value) => null);
            // } else if (_status.isNotEmpty &&
            //     _status.contains("Already register")) {
            //   _checkService().then((value) => null);
            // } else if (_status.isNotEmpty &&
            //     _status.contains("POS service check passed")) {
            //   _startTransaction().then((value) => null);
            // }
          });
        }
        print('📱 Native Event: $event');
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _status = 'Error: $err';
          });
        }
        print('❌ Event Stream Error: $err');
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;

    try {
      platformVersion = await _softposafsPlugin.getPlatformVersion();
      _status = platformVersion ?? 'Unknown platform version';
    } on PlatformException catch (e) {
      _status = 'Failed to get platform version: ${e.message}';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion ?? 'Unknown';
    });
  }

  Future<void> _initSDK() async {
    try {
      String softPosURL = "https://soharpay.uat.afs.com.bh/core";
      final result = await _softposafsPlugin.initializeSDK(softPosURL);
      if (mounted) {
        setState(() {
          _status = result ?? "SDK initialization response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "SDK initialization failed: $e";
        });
      }
    }
  }

  Future<void> _checkService() async {
    try {
      final result = await _softposafsPlugin.checkPOSService();
      if (mounted) {
        setState(() {
          _status = result ?? "POS service check response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "POS service check failed: $e";
        });
      }
    }
  }

  Future<void> _registerDevice() async {
    try {
      String merchantId = "220000000209890";
      String terminalId = "22949347";
      String activationCode = "1";
      final result = await _softposafsPlugin.registerDevice(
          merchantId, terminalId, activationCode);
      if (mounted) {
        setState(() {
          _status = result ?? "Device registration response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Device registration failed: $e";
        });
      }
    }
  }

  Future<void> _unregisterDevice() async {
    try {
      final result = await _softposafsPlugin.unregisterDevice();
      if (mounted) {
        setState(() {
          _status = result ?? "Device unregistration response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Device unregistration failed: $e";
        });
      }
    }
  }

  Future<void> _startTransaction() async {
    try {
      int transactionId = DateTime.now().millisecondsSinceEpoch;
      final result =
          await _softposafsPlugin.startTransaction(transactionId, 10000);
      if (mounted) {
        setState(() {
          _status = result ?? "Transaction start response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Transaction start failed: $e";
        });
      }
    }
  }

  Future<void> startPayment() async {
    try {
      String softPosURL = "https://soharpay.uat.afs.com.bh/core";
      final result = await _softposafsPlugin.initializeSDK(softPosURL);
      if (mounted) {
        setState(() {
          _status = result ?? "Device registration response is null";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Device registration failed: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _eventSubscription.cancel(); // ✅ Clean up stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SoftPOS Plugin Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _status.startsWith('❌') || _status.startsWith('Error')
                              ? Colors.red
                              : _status.startsWith('✅')
                                  ? Colors.green
                                  : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _initSDK,
                    child: const Text("Initialize SDK"),
                  ),
                  ElevatedButton(
                    onPressed: _checkService,
                    child: const Text("Check POS Service"),
                  ),
                  ElevatedButton(
                    onPressed: _registerDevice,
                    child: const Text("Register Device"),
                  ),
                  ElevatedButton(
                    onPressed: _unregisterDevice,
                    child: const Text("Unregister Device"),
                  ),
                  ElevatedButton(
                    onPressed: _startTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Start Transaction"),
                  ),
                  ElevatedButton(
                    onPressed: startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Start PaymentProcess"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

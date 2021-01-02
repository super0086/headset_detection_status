import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:headset_detection_status/headset_detect.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  HeadsetState state = HeadsetState();

  final HeadsetDetect _headsetDetect = HeadsetDetect();
  StreamSubscription<HeadsetState> _subscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _subscription =
        _headsetDetect.onHeadsetStateChanged.listen(_updateHeadsetState);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    HeadsetState result;
    try {
      result = await _headsetDetect.checkHeadset();
    } on PlatformException {}
    if (!mounted) return;

    _updateHeadsetState(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Headset Plugin example app'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Version : $_platformVersion\n'),
            Text('有线耳机状态:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.headset,
                  color: this.state.wired == HeadsetStateEnum.CONNECTED
                      ? Colors.green
                      : Colors.red,
                ),
                Text('  ${state.wired} '),
              ],
            ),
            Text('蓝牙耳机状态:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth,
                  color: this.state.bluetooth == HeadsetStateEnum.CONNECTED
                      ? Colors.green
                      : Colors.red,
                ),
                Text('    ${state.bluetooth}'),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Future<void> _updateHeadsetState(HeadsetState result) async {
    print(
        '==>_updateHeadsetState wired:${result.wired} bluetooth:${result.bluetooth}');
    setState(() => state = result);
  }
}

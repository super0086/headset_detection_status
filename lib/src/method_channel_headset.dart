import 'package:flutter/services.dart';

import 'headset_state.dart';

class MethodChannelHeadset {
  static MethodChannelHeadset _instance = MethodChannelHeadset();
  // ignore: unnecessary_getters_setters
  static MethodChannelHeadset get instance => _instance;
  // ignore: unnecessary_getters_setters
  static set instance(MethodChannelHeadset newInstance) {
    _instance = newInstance;
  }

  //原生交互数据通道
  MethodChannel methodChannel = MethodChannel('method_headset_detect');
  //接受原生数据HeadsetState的receive
  EventChannel eventChannel = EventChannel('event_headset_detect');

  Stream<HeadsetState> _onHeadsetStateChanged;

  ///检测获取耳机状态
  Future<HeadsetState> checkHeadset() {
    return methodChannel
        .invokeMethod<Map<dynamic, dynamic>>("getHeadsetState")
        .then(parseHeadsetState);
  }

  ///耳机状态改变
  Stream<HeadsetState> get onHeadsetStateChanged {
    if (_onHeadsetStateChanged == null) {
      _onHeadsetStateChanged = eventChannel
          .receiveBroadcastStream()
          .map((dynamic result) => Map<String, int>.from(result))
          .map(parseHeadsetState);
    }
    return _onHeadsetStateChanged;
  }
}

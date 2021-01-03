import 'package:headset_detection_status/src/headset_state.dart';
import 'package:headset_detection_status/src/method_channel_headset.dart';

///耳机状态检测(蓝牙耳机、有线耳机)
class HeadsetDetect {
  /// [HeadsetDetect] is designed to work as a singleton.
  factory HeadsetDetect() {
    if (_singleton == null) {
      _singleton = HeadsetDetect._();
    }
    return _singleton;
  }

  HeadsetDetect._();

  static HeadsetDetect _singleton;

  static MethodChannelHeadset get _channel => MethodChannelHeadset.instance;

  Future<HeadsetState> checkHeadset() {
    return _channel.checkHeadset();
  }

  Stream<HeadsetState> get onHeadsetStateChanged {
    return _channel.onHeadsetStateChanged;
  }
}

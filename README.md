# headset_detection_status

耳机状态监听，包括有线耳机和蓝牙耳机。获取当前耳机状态，监听耳机并实时获取状态。

# 说明

可以主动获取耳机状态，也可以动态实时监听耳机的状态。支持的耳机类型包括有线耳机、蓝牙耳机，同时支持ios和android平台。

# Usage

Sample usage

## Example

获取耳机状态
```dart
import 'package:headset_detection_status/headset_detect.dart';

final HeadsetDetect _headsetDetect = HeadsetDetect();
HeadsetState state = await _headsetDetect.checkHeadset();
if (state.wired == HeadsetStateEnum.CONNECTED) {
    //有线耳机已连接
} else if(state.wired == HeadsetStateEnum.DISCONNECTED) {
    //有线耳机已断开
}
```

监听耳机状态
```dart
final HeadsetDetect _headsetDetect = HeadsetDetect();
StreamSubscription<HeadsetState> _subscription = 
_headsetDetect.onHeadsetStateChanged.listen((HeadsetState state) {
    if (state.bluetooth == HeadsetStateEnum.CONNECTED) {
        //蓝牙耳机已连接
    } else if(state.bluetooth == HeadsetStateEnum.DISCONNECTED) {
        //蓝牙耳机已断开
    }
});


```
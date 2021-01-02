enum HeadsetStateEnum {
  DISCONNECTED, //已断开 0
  CONNECTED, //已连接 1
  DISCONNECTING, //断开中 2
  CONNECTING, //连接中 3
  UNKNOWN, //未知 -1
}

HeadsetState parseHeadsetState(Map<dynamic, dynamic> result) {
  return HeadsetState.formJson(result);
}

class HeadsetState {
  HeadsetStateEnum wired;
  HeadsetStateEnum bluetooth;

  HeadsetState(
      {this.wired = HeadsetStateEnum.UNKNOWN,
      this.bluetooth = HeadsetStateEnum.UNKNOWN});

  HeadsetState.formJson(Map<dynamic, dynamic> map) {
    int wiredInt = map['wired'] == null ? -1 : map['wired'] as int;
    int bluetoothInt = map['bluetooth'] == null ? -1 : map['bluetooth'] as int;
    wired = _stateEnum(wiredInt);
    bluetooth = _stateEnum(bluetoothInt);
  }

  _stateEnum(int state) {
    switch (state) {
      case 0:
        return HeadsetStateEnum.DISCONNECTED;
      case 1:
        return HeadsetStateEnum.CONNECTED;
      case 2:
        return HeadsetStateEnum.DISCONNECTING;
      case 3:
        return HeadsetStateEnum.CONNECTING;
      default:
        return HeadsetStateEnum.UNKNOWN;
    }
  }
}

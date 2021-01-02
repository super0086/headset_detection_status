package com.mervyn.headset_detection_status;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;

public class Headset {
    private final String TAG = "Headset";

    private Context mContext;
    private BluetoothManager bluetoothManager;
    private BluetoothAdapter bluetoothAdapter;
    private HeadsetState lastWiredState;

    public Headset(Context context) {
        mContext = context;
        bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
        lastWiredState = HeadsetState.UNKNOWN;
    }

    //获取当前设备状态（有线耳机和蓝牙耳机）
    public StateResult getCurrentState() {
        HeadsetState blue = getBluetoothState();
        HeadsetState wired = lastWiredState;
        return new StateResult(wired.getState(), blue.getState());
    }

    //获取蓝牙设备状态
    private HeadsetState getBluetoothState() {
        try {
            if (bluetoothAdapter.isEnabled()) {
                int a2dp = bluetoothAdapter.getProfileConnectionState(BluetoothProfile.A2DP); // 可操控蓝牙设备，如带播放暂停功能的蓝牙耳机
                int headset = bluetoothAdapter.getProfileConnectionState(BluetoothProfile.HEADSET); // 蓝牙头戴式耳机，支持语音输入输出
                int health = bluetoothAdapter.getProfileConnectionState(BluetoothProfile.HEALTH); // 蓝牙穿戴式设备
                Log.e("Headset", "getBlueState a2dp=" + a2dp + ",headset=" + headset + ",health=" + health);
                // 查看是否蓝牙是否连接到三种设备的一种，以此来判断是否处于连接状态还是打开并没有连接的状态
                int state = -1;
                if (a2dp == BluetoothProfile.STATE_CONNECTED) {
                    state = a2dp;
                } else if (headset == BluetoothProfile.STATE_CONNECTED) {
                    state = headset;
                } else if (health == BluetoothProfile.STATE_CONNECTED) {
                    state = health;
                }
                if (state !=-1) {
                    return HeadsetState.CONNECTED;
                }
                return HeadsetState.DISCONNECTED;
            }
            return HeadsetState.DISCONNECTED;
        } catch (Exception e) {
            return HeadsetState.DISCONNECTED;
        }
    }

    public void eventHeadset(EventChannel.EventSink events, HeadsetState state, boolean isBlue) {
        Log.i(TAG, "===> eventHeadset state:" + state.getState() + ",method:" + state.getMethod() + (isBlue ? ",isBlue" : ",isWired"));
        HeadsetState wired;
        HeadsetState blue;
        if (isBlue) {
            wired = lastWiredState;
            blue = state;
        } else {
            lastWiredState = wired = state;
            blue = getBluetoothState();
        }
        StateResult result = new StateResult(wired.getState(), blue.getState());
        Log.i(TAG, "===>java native eventHeadset wired:" + result.wired + ",blue:" + result.bluetooth + (isBlue ? ",isBlue" : ",isWired"));
        events.success(result.toHashMap());
    }
}
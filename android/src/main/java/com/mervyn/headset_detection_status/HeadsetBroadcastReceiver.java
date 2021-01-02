package com.mervyn.headset_detection_status;

import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;

public class HeadsetBroadcastReceiver extends BroadcastReceiver
        implements EventChannel.StreamHandler {

    private final String TAG = "HeadsetBroadcastReceiver";
    private Context context;
    private EventChannel.EventSink events;
    private Headset headset;
    private boolean isBlue = true;

    public HeadsetBroadcastReceiver(Context context, Headset headset) {
        this.context = context;
        this.headset = headset;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.i(TAG, "==========>java native headset onListen");
        this.events = events;
        String actionHeadsetPlug = Intent.ACTION_HEADSET_PLUG;
        String actionBluetoothConnectionState = BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED;
        String actionBluetoothState = BluetoothAdapter.ACTION_STATE_CHANGED;
        IntentFilter filter = new IntentFilter();
        filter.addAction(actionHeadsetPlug);
        filter.addAction(actionBluetoothConnectionState);
        filter.addAction(actionBluetoothState);
        context.registerReceiver(this, filter);
    }

    @Override
    public void onCancel(Object arguments) {
        this.events = null;
        context.unregisterReceiver(this);
        Log.i(TAG, "==========>java native headset onCancel:unregisterReceiver");
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        int stateValue = 0;
        switch (action) {
            case Intent.ACTION_HEADSET_PLUG:
                stateValue = intent.getIntExtra("state", 0);
                wiredHeadset(stateValue);
                break;
            case BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED:
                stateValue = intent.getIntExtra(BluetoothAdapter.EXTRA_CONNECTION_STATE, 0);
                bluetoothConnectionStateChanged(stateValue);
                break;
            case BluetoothAdapter.ACTION_STATE_CHANGED:
                stateValue = intent.getExtras().getInt(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR);
                bluetoothStateChanged(stateValue);
                break;
            default:
                Log.i(TAG, "==========>onReceive OTHER");
                abortBroadcast();
                break;
        }
    }

    private void wiredHeadset(int stateValue) {
        Log.i(TAG, "==========>onReceive HEADSET stateValue:" + stateValue);
        HeadsetState _state = HeadsetState.UNKNOWN;
        if (stateValue == 0) { // 未插入有线耳机设备
            _state = HeadsetState.DISCONNECTED;
        } else if (stateValue == 1) {
            _state = HeadsetState.CONNECTED;
        }
        headset.eventHeadset(events, _state, !isBlue);
    }

    private void bluetoothConnectionStateChanged(int stateValue) {
        Log.i(TAG, "==========>onReceive CONNECTION_STATE_CHANGED stateValue:" + stateValue);
        HeadsetState _state;
        switch (stateValue) {
            case BluetoothAdapter.STATE_CONNECTED:
                _state = HeadsetState.CONNECTED;
                break;
            case BluetoothAdapter.STATE_CONNECTING:
                _state = HeadsetState.CONNECTING;
                break;
            case BluetoothAdapter.STATE_DISCONNECTING:
                _state = HeadsetState.DISCONNECTING;
                break;
            case BluetoothAdapter.STATE_DISCONNECTED:
                _state = HeadsetState.DISCONNECTED;
                break;
            default:
                _state = HeadsetState.UNKNOWN;
                break;
        }
        headset.eventHeadset(events, _state, isBlue);
    }

    private void bluetoothStateChanged(int stateValue) {
        Log.i(TAG, "==========>onReceive STATE_CHANGED stateValue:" + stateValue);
        HeadsetState _state;
        switch (stateValue) {
            case BluetoothAdapter.STATE_ON:
                _state = HeadsetState.CONNECTED;
                break;
            case BluetoothAdapter.STATE_TURNING_ON:
                _state = HeadsetState.CONNECTING;
                break;
            case BluetoothAdapter.STATE_TURNING_OFF:
                _state = HeadsetState.DISCONNECTING;
                break;
            case BluetoothAdapter.STATE_OFF:
                _state = HeadsetState.DISCONNECTED;
                break;
            default:
                _state = HeadsetState.UNKNOWN;
                break;
        }
        headset.eventHeadset(events, _state, isBlue);
    }

}
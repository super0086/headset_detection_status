package com.mervyn.headset_detection_status;

import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class HeadsetMethodChannelHandler implements MethodChannel.MethodCallHandler {

    private final String TAG = "HeadsetMethodChannelHandler";
    private Headset headset;

    public HeadsetMethodChannelHandler(Headset headset) {
        this.headset = headset; 
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getHeadsetState")) {
            StateResult state = headset.getCurrentState();
            Log.i(TAG, "==========>java native headset getHeadsetWiredState:" + state.wired);
            Log.i(TAG, "==========>java native headset getHeadsetBlueState:" + state.bluetooth);
            result.success(state.toHashMap());
        } else {
            Log.i(TAG, "==========>java native headset other MethodCall...");
            result.notImplemented();
        }
    }

}

package com.mervyn.headset_detection_status;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * 有线耳机、蓝牙耳机设备状态监控
 */
public class HeadsetDetectionStatusPlugin implements FlutterPlugin {

    private final static String TAG = "HeadsetDetectionStatusPlugin";
    private final String CHANNEL_NAME = "method_headset_detect";
    private final String EVENT_CHANNEL_NAME = "event_headset_detect";

    private Object initializationLock = new Object();
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private Headset headset;

    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        Log.i(TAG, "==========>java native headset event registerWith");
        HeadsetDetectionStatusPlugin instance = new HeadsetDetectionStatusPlugin();
        instance.setup(registrar.messenger(), registrar.context());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Log.i(TAG, "==========>java native headset event onAttachedToEngine");
        setup(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        teardown();
    }

    private void setup(BinaryMessenger messenger, Context context) {
        synchronized (initializationLock) {
            if (methodChannel != null && eventChannel != null) {
                return;
            }
            methodChannel = new MethodChannel(messenger, CHANNEL_NAME);
            eventChannel = new EventChannel(messenger, EVENT_CHANNEL_NAME);
            if (headset == null) {
                headset = new Headset(context);
            }
            HeadsetMethodChannelHandler handler = new HeadsetMethodChannelHandler(headset);
            HeadsetBroadcastReceiver receiver = new HeadsetBroadcastReceiver(context, headset);

            methodChannel.setMethodCallHandler(handler);
            eventChannel.setStreamHandler(receiver);
        }
    }

    private void teardown() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        methodChannel = null;
        eventChannel = null;
    }

}

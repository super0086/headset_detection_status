#import "HeadsetDetectionStatusPlugin.h"
#import "AVFoundation/AVFoundation.h"
#import "UIKit/UIKit.h"

typedef NS_ENUM(NSInteger, HEADSET_STATE)
{
    HEADSET_STATE_DISCONNECTED = 0, //断开连接
    HEADSET_STATE_CONNECTED = 1, //已连接
    HEADSET_STATE_DISCONNECTING = 2, //断开中
    HEADSET_STATE_CONNECTING = 3, //连接中
    HEADSET_STATE_UNKNOWN = -1, // 未知
};

@interface HeadsetDetectionStatusPlugin()<FlutterStreamHandler>
    @property(nonatomic, retain) FlutterMethodChannel *methodChannel;
    @property(nonatomic, retain) FlutterEventChannel *eventChannel;
@end

@implementation HeadsetDetectionStatusPlugin
{
    FlutterEventSink _eventSink;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  HeadsetDetectionStatusPlugin* instance = [[HeadsetDetectionStatusPlugin alloc] init];
  FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName:@"method_headset_detect"
                                                              binaryMessenger:[registrar messenger]];
  FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"event_headset_detect"
                                                                  binaryMessenger:[registrar messenger]];
  instance.methodChannel = methodChannel;
  instance.eventChannel = eventChannel;
  [eventChannel setStreamHandler: instance];
  [registrar addMethodCallDelegate:instance channel:methodChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSLog(@"【Headset event Plugin】【iOS】 接收到方法==> %@", call.method);
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"getHeadsetState" isEqualToString:call.method]) {
      id stateResult = [self getHeadsetState];
      result(stateResult);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(id) getHeadsetState {
    NSInteger wired = HEADSET_STATE_UNKNOWN;
    NSInteger bluetooth = HEADSET_STATE_UNKNOWN;
    AVAudioSessionRouteDescription* currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray<AVAudioSessionPortDescription *> *outputs = [currentRoute outputs];
    for (AVAudioSessionPortDescription* desc in outputs) {
        NSLog(@"==>portType:%@", [desc portType]);
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            //耳机
            wired = HEADSET_STATE_CONNECTED;
            break;
        }
        if ([[desc portType] isEqualToString:AVAudioSessionPortBluetoothLE]) {
            //Bluetooth Low Energy 低功耗蓝牙
            bluetooth = HEADSET_STATE_CONNECTED;
            break;
        }
        if ([[desc portType] isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            //蓝牙可以控制电话，如接听、挂断、拒接、语音拨号等
            bluetooth = HEADSET_STATE_CONNECTED;
            break;
        }
        if ([[desc portType] isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            //蓝牙可以控制电话，如接听、挂断、拒接、语音拨号等
            bluetooth = HEADSET_STATE_CONNECTED;
            break;
        }
    }
    if (wired == HEADSET_STATE_UNKNOWN) {
        wired = HEADSET_STATE_DISCONNECTED;
    }
    if (bluetooth == HEADSET_STATE_UNKNOWN) {
        bluetooth = HEADSET_STATE_DISCONNECTED;
    }
    NSNumber *wiredNum = [NSNumber numberWithLong:wired];
    NSNumber *bluetoothNum = [NSNumber numberWithLong:bluetooth];
    NSLog(@"【Get ios Plugin HeadsetState】wired:%@ bluetooth:%@", wiredNum, bluetoothNum);
    id stateResult = [self stateResultWired:wiredNum bluetooth:bluetoothNum];
    return stateResult;
}

-(void) registerAudioRouteChangeBlock {
    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(execute:)
     name:AVAudioSessionRouteChangeNotification
     object:AVAudioSession.sharedInstance];
}

-(void) execute:(NSNotification *)notification {
    NSLog(@"【ios Headset event Plugin】notification");
    id stateResult = [self getHeadsetState];
    NSLog(@"【ios Headset event Plugin】notification wired:%@ bluetooth:%@",stateResult[@"wired"],stateResult[@"bluetooth"]);
    _eventSink(stateResult);
    /*
    NSDictionary* userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
//    int iii = [userInfo[AVAudioSessionRouteChangeReasonKey] intValue];
//    NSLog(@"【ios Headset event Plugin】notification iii:%d", iii);
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        NSLog(@"【ios Headset event Plugin】notification AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
        AVAudioSessionRouteDescription *routeDescription = userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *desc = [routeDescription.outputs firstObject];
        NSLog(@"==> notification portType:%@", [desc portType]);
        //原设备为耳机则暂停
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            NSLog(@"==> notification 原设备为耳机则暂停");
        }
//        if (state == 0) {
//            [[self channel] invokeMethod:@"disconnect" arguments:@"true"];
//        }
    } else if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        NSLog(@"【ios Headset event Plugin】notification AVAudioSessionRouteChangeReasonNewDeviceAvailable");
        AVAudioSessionRouteDescription *routeDescription = userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *desc = [routeDescription.outputs firstObject];
        NSLog(@"==> notification portType:%@", [desc portType]);
        //原设备为耳机则暂停
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            NSLog(@"==> notification 原设备为耳机则暂停");
        }
//        [[self channel] invokeMethod:@"connect" arguments:@"true"];
        
    } else { // 其它
        NSLog(@"【ios Headset event Plugin】notification other Reason");
    }
    // */
}

-(id) stateResultWired:(NSNumber *) wired bluetooth:(NSNumber *)bluetooth {
    return @{@"wired" : wired, @"bluetooth" : bluetooth};
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [self registerAudioRouteChangeBlock];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

@end

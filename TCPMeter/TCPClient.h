//
//  TCPClient.h
//  TCPMeter
//
//  Created by Karolis Stašaitis on 4/9/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface TCPClient : NSObject <AsyncSocketDelegate>
{
    AsyncSocket *socket;
    NSString *lastHost;
    int lastPort;
    int connectionAttempts;
    BOOL tryReconnecting;
}

- (void)connectWithHost:(NSString *)host port:(int)port;
- (void)sendMotionDataPitch:(float)pitch Roll:(float)roll Yaw:(float)yaw;
- (void)sendLocationDataLatitude:(float)latitude Longitude:(float)longitude horizontalAccuracy:(float)horizontalAccuracy verticalAccuracy:(float)verticalAccuracy;


@end

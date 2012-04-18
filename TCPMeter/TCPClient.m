//
//  TCPClient.m
//  TCPMeter
//
//  Created by Karolis Stašaitis on 4/9/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#import "TCPClient.h"
#import "Constants.h"

@implementation TCPClient

- (id)init
{
    self = [super init];
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    return self;
}

- (void)connectWithHost:(NSString *)host port:(int)port
{    
    connectionAttempts = 0;
    lastHost = host;
    lastPort = port;
    [self reconnect];
}

- (void)reconnect
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTING_NOTIFICATION object:self];
    
    connectionAttempts++;
    NSError *error;
    if([socket connectToHost:lastHost onPort:lastPort withTimeout:CONNECTION_TIMEOUT_DURATION error:&error])
    {
        [socket readDataWithTimeout:-1 tag:0];
    } else {
        NSLog(@"%@",error);
        if (connectionAttempts < MAX_RECONNECTION_TRIES) [self reconnect];
    }
}

- (void)tryConnectingAfterInterval:(NSTimer *)timer
{
    [self reconnect];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"%@",err);
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTED_NOTIFICATION object:self];
    connectionAttempts = 0;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECTED_NOTIFICATION object:self];
    if (connectionAttempts < MAX_RECONNECTION_TRIES) [[NSRunLoop mainRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:RECONNECTION_INTERVAL target:self selector:@selector(tryConnectingAfterInterval:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (void)sendLocationDataLatitude:(float)latitude Longitude:(float)longitude horizontalAccuracy:(float)horizontalAccuracy verticalAccuracy:(float)verticalAccuracy
{
    if(socket.isConnected)
    {
        NSString *dataString = [NSString stringWithFormat:@"%@: %.6f %.6f %.2f %.2f",GPS_RESPONSE_HEADER,latitude,longitude,horizontalAccuracy,verticalAccuracy];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:DATAWRITE_TIMEOUT_DURATION tag:GPS_DATA_RESPONSE_TAG];
    }
}

- (void)sendMotionDataPitch:(float)pitch Roll:(float)roll Yaw:(float)yaw
{
    if(socket.isConnected)
    {
        NSString *dataString = [NSString stringWithFormat:@"%@: %.3f %.3f %.3f",MOTION_RESPONSE_HEADER,pitch,roll,yaw];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:DATAWRITE_TIMEOUT_DURATION tag:MOTION_DATA_RESPONSE_TAG];
    }
} 

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if([dataString isEqualToString:GPS_REQUEST_CMD])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GPS_REQUEST_NOTIFICATION object:self];
    } else if ([dataString isEqualToString:MOTION_REQUEST_CMD]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MOTION_REQUEST_NOTIFICATION object:self];
    }
    
    [socket readDataWithTimeout:DATAWRITE_TIMEOUT_DURATION tag:0];
}

@end

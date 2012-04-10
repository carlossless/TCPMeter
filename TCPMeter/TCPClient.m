//
//  TCPClient.m
//  TCPMeter
//
//  Created by Karolis Stašaitis on 4/9/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#import "TCPClient.h"

#define GPS_DATA_REQUEST 11
#define MOTION_DATA_REQUEST 12
#define GPS_DATA_RESPONSE 13
#define MOTION_DATA_RESPONSE 14

@implementation TCPClient

- (id)init
{
    self = [super init];
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    return self;
}

- (void)connectWithHost:(NSString *)host port:(int)port
{    
    if (![lastHost isEqualToString:host] || lastPort != port)
    {
        connectionAttempts = 0;
        lastHost = host;
        lastPort = port;
    }
    
    NSError *error;
    if([socket connectToHost:host onPort:port error:&error])
    {
        [socket readDataWithTimeout:-1 tag:0];
        connectionAttempts = 0;
    } else {
        NSLog(@"%@",error);
        connectionAttempts++;
        [self connectWithHost:host port:port];
    }
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"%@",err);
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectedToServer" object:self];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisconnectedFromServer" object:self];
}

- (void)sendLocationDataLatitude:(float)latitude Longitude:(float)longitude
{
    if(socket.isConnected)
    {
        NSString *dataString = [NSString stringWithFormat:@"GPS: %.6f %.6f",latitude,longitude];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:20 tag:GPS_DATA_RESPONSE];
    }
}

- (void)sendMotionDataPitch:(float)pitch Roll:(float)roll Yaw:(float)yaw
{
    if(socket.isConnected)
    {
        NSString *dataString = [NSString stringWithFormat:@"MOTION: %.3f %.3f %.3f",pitch,roll,yaw];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [socket writeData:data withTimeout:20 tag:MOTION_DATA_RESPONSE];
    }
} 

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if([dataString isEqualToString:@"GPS_REQUEST"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GPSDataRequest" object:self];
    } else if ([dataString isEqualToString:@"MOTION_REQUEST"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MotionDataRequest" object:self];
    }
    
    [socket readDataWithTimeout:-1 tag:0];
}

@end

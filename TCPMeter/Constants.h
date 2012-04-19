//
//  Constants.h
//  TCPMeter
//
//  Created by Karolis Stašaitis on 4/18/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#ifndef TCPMeter_Constants_h
#define TCPMeter_Constants_h

#define DEFAULT_HOST @"hostname.here"
#define DEFAULT_PORT @"6666"

#define GPS_REQUEST_CMD @"GPS_REQUEST"
#define MOTION_REQUEST_CMD @"MOTION_REQUEST"

#define GPS_RESPONSE_HEADER @"GPS"
#define MOTION_RESPONSE_HEADER @"MOTION"

#define GPS_DATA_RESPONSE_TAG 10
#define MOTION_DATA_RESPONSE_TAG 11

#define GPS_REQUEST_NOTIFICATION @"GPSDataRequest"
#define MOTION_REQUEST_NOTIFICATION @"MotionDataRequest"
#define CONNECTED_NOTIFICATION @"ConnectedToServer"
#define CONNECTING_NOTIFICATION @"ConnectingToServer"
#define DISCONNECTED_NOTIFICATION @"DisconnectedFromServer"
#define RECONNECTION_STARTED_NOTIFICATION @"ReconnectionStarted"
#define RECONNECTION_STOPPED_NOTIFICATION @"ReconnectionStoped"
#define STOP_RECONECTION_NOTIFICATION @"StopReconnection"
#define MAX_RECONNECTION_TRIES 10

#define SERVER_HOST_KEY @"ServerHost"
#define SERVER_PORT_KEY @"ServerKey"

#define CONNECTION_TIMEOUT_DURATION 5.0f
#define DATAREAD_TIMEOUT_DURATION -1 //Infinite
#define DATAWRITE_TIMEOUT_DURATION 20.0f
#define RECONNECTION_INTERVAL 2.0f

#endif

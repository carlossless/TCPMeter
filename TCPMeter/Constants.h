//
//  Constants.h
//  TCPMeter
//
//  Created by Karolis Stašaitis on 4/18/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#ifndef TCPMeter_Constants_h
#define TCPMeter_Constants_h

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

#define MAX_RECONNECTION_TRIES 10

#define RECONNECTION_INTERVAL 2.0f

#endif

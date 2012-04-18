//
//  ViewController.m
//  TCPMeter
//
//  Created by Karolis Stašaitis on 3/29/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#import "ViewController.h"
#import "TCPClient.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize locationLatitudeView = _locationLatitudeView;
@synthesize locationLongitudeView = _locationLongitudeView;
@synthesize motionPitchView = _motionPitchView;
@synthesize motionRollView = _motionRollView;
@synthesize motionYawView = _motionYawView;
@synthesize locationManager = _locationManager;
@synthesize motionManager = _motionManager;
@synthesize accuracyView = _accuracyView;
@synthesize rateView = _rateView;
@synthesize serverStatusView = _serverStatusView;
@synthesize accuracyStepper = _accuracyStepper;
@synthesize rateStepper = _rateStepper;
@synthesize client = _client;
@synthesize lastMotionValue = _lastMotionValue;
@synthesize lastLocationValue = _lastLocationValue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self switchGPSAccuracy:lroundf(self.accuracyStepper.value)];
    self.locationManager.distanceFilter = 0;
    self.locationManager.delegate = self;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/lroundf(self.rateStepper.value);
    NSOperationQueue *opQ = [NSOperationQueue currentQueue];
    CMDeviceMotionHandler motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        self.motionPitchView.text = [NSString stringWithFormat:@"Pitch: %.3f",motion.attitude.pitch];
        self.motionRollView.text = [NSString stringWithFormat:@"Roll: %.3f",motion.attitude.roll];
        self.motionYawView.text = [NSString stringWithFormat:@"Yaw: %.3f",motion.attitude.yaw];
        self.lastMotionValue = motion;
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConnectionStatusChangeNotification:) name:CONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConnectionStatusChangeNotification:) name:DISCONNECTED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveDataRequestNotification:) name:GPS_REQUEST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveDataRequestNotification:) name:MOTION_REQUEST_NOTIFICATION object:nil];
    
    [self.locationManager startUpdatingLocation];
    [self.motionManager startDeviceMotionUpdatesToQueue:opQ withHandler:motionHandler];
    
    self.serverStatusView.text = @"Connecting...";
    self.client = [[TCPClient alloc] init];
    [self.client connectWithHost:@"mindw0rk.local" port:6613];
}

- (void)viewDidUnload
{
    [self setAccuracyView:nil];
    [self setRateView:nil];
    [self setServerStatusView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)recieveDataRequestNotification:(NSNotification *)notification
{
    if (notification.name == GPS_REQUEST_NOTIFICATION) {
        [self.client sendLocationDataLatitude:self.lastLocationValue.coordinate.latitude Longitude:self.lastLocationValue.coordinate.longitude horizontalAccuracy:self.lastLocationValue.horizontalAccuracy verticalAccuracy:self.lastLocationValue.verticalAccuracy];
    } else if (notification.name == MOTION_REQUEST_NOTIFICATION) {
        [self.client sendMotionDataPitch:self.lastMotionValue.attitude.pitch Roll:self.lastMotionValue.attitude.roll Yaw:self.lastMotionValue.attitude.yaw];
    }
}

- (void)serverConnectionStatusChangeNotification:(NSNotification *)notification
{
    if (notification.name == CONNECTED_NOTIFICATION) {
        self.serverStatusView.text = @"Connected";
    } else if (notification.name == DISCONNECTED_NOTIFICATION) {
        self.serverStatusView.text = @"Disconnected";
    }
}

- (IBAction)gpsAccuracyChanged:(id)sender
{
    UIStepper *accuracyStepper = sender;
    [self switchGPSAccuracy:lroundf(accuracyStepper.value)];
}

- (void)switchGPSAccuracy:(int)value
{
    switch (value) {
        case 0:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            self.accuracyView.text = @"Accuracy: 3km";
            break;
        case 1:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            self.accuracyView.text = @"Accuracy: 1km";
            break;
        case 2:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.accuracyView.text = @"Accuracy: 100m";
            break;
        case 3:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            self.accuracyView.text = @"Accuracy: 10m";
            break;
        default:
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.accuracyView.text = @"Accuracy: Best";
            break;
    }
}

- (IBAction)refreshRateChanged:(id)sender {
    UIStepper *rateStepper = sender;
    self.motionManager.deviceMotionUpdateInterval = 1.0/lroundf(rateStepper.value);
    self.rateView.text = [NSString stringWithFormat:@"Refresh Rate: %dHz",lroundf(rateStepper.value)];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.locationLatitudeView.text = [NSString stringWithFormat:@"Latitude %f",newLocation.coordinate.latitude];
    self.locationLongitudeView.text = [NSString stringWithFormat:@"Longitude %f",newLocation.coordinate.longitude];
    self.lastLocationValue = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        //[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

@end

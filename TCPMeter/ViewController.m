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
@synthesize mainScrollView = _mainScrollView;
@synthesize hostnameTextView = _hostnameTextView;
@synthesize portTextView = _portTextView;
@synthesize connectButton = _connectButton;
@synthesize accuracyStepper = _accuracyStepper;
@synthesize rateStepper = _rateStepper;
@synthesize client = _client;
@synthesize lastMotionValue = _lastMotionValue;
@synthesize lastLocationValue = _lastLocationValue;
@synthesize connectionButtonStatus = _connectionButtonStatus;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initiating location services
    self.locationManager = [[CLLocationManager alloc] init];
    [self switchGPSAccuracy:lroundf(self.accuracyStepper.value)];
    self.locationManager.distanceFilter = 0;
    self.locationManager.delegate = self;
    
    //Initiating motion services
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/lroundf(self.rateStepper.value);
    NSOperationQueue *opQ = [NSOperationQueue currentQueue];
    CMDeviceMotionHandler motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        self.motionPitchView.text = [NSString stringWithFormat:@"Pitch: %.3f",motion.attitude.pitch];
        self.motionRollView.text = [NSString stringWithFormat:@"Roll: %.3f",motion.attitude.roll];
        self.motionYawView.text = [NSString stringWithFormat:@"Yaw: %.3f",motion.attitude.yaw];
        self.lastMotionValue = motion;
    };
    
    //View specific parameters
    self.hostnameTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_HOST_KEY];
    self.portTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:SERVER_PORT_KEY];
    if ([self.hostnameTextView.text length] == 0 || [self.portTextView.text length] == 0 )
    {
        self.hostnameTextView.text = DEFAULT_HOST;
        self.portTextView.text = DEFAULT_PORT;
    }
    self.hostnameTextView.delegate = (id)self;
    self.portTextView.delegate = (id)self;
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width,455);
    self.connectionButtonStatus = false;
    
    //Server related notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConnectionStatusChangeNotification:) name:CONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConnectionStatusChangeNotification:) name:CONNECTING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConnectionStatusChangeNotification:) name:DISCONNECTED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverReconnectionStatusChangeNotification:) name:RECONNECTION_STARTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverReconnectionStatusChangeNotification:) name:RECONNECTION_STOPPED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveDataRequestNotification:) name:GPS_REQUEST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveDataRequestNotification:) name:MOTION_REQUEST_NOTIFICATION object:nil];
    
    //Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    //Start data retrieval services
    [self.locationManager startUpdatingLocation];
    [self.motionManager startDeviceMotionUpdatesToQueue:opQ withHandler:motionHandler];
    
    //Initiate tcp/ip client
    self.client = [[TCPClient alloc] init];
}

- (void)viewDidUnload
{
    [self setAccuracyView:nil];
    [self setRateView:nil];
    [self setServerStatusView:nil];
    [self setMainScrollView:nil];
    [self setHostnameTextView:nil];
    [self setConnectButton:nil];
    [self setPortTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [[NSUserDefaults standardUserDefaults] setObject:self.hostnameTextView.text forKey:SERVER_HOST_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:self.portTextView.text forKey:SERVER_PORT_KEY];
    [theTextField resignFirstResponder];
    return YES;
}

- (void)selectionDidChange:(UITextField *)textInput
{
    
}

- (void)selectionWillChange:(id <UITextInput>)textInput
{
    
}

- (void)textDidChange:(id <UITextInput>)textInput
{
    
}

- (void)textWillChange:(id <UITextInput>)textInput
{
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 172, 0.0);
    self.mainScrollView.contentInset = contentInsets;
    self.mainScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= 172;
    if (!CGRectContainsPoint(aRect, self.hostnameTextView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.hostnameTextView.frame.origin.y-172);
        [self.mainScrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.mainScrollView.contentInset = contentInsets;
    self.mainScrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)connectButtonPressed:(id)sender
{   
    if (!self.connectionButtonStatus) {
        self.connectionButtonStatus = 1;
        [self.client connectWithHost:self.hostnameTextView.text port:[self.portTextView.text intValue]];
    } else {
        self.connectionButtonStatus = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:STOP_RECONECTION_NOTIFICATION object:self];
        self.serverStatusView.text = @"Stopping...";
    }
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
        [self.connectButton setTitle:@"Disconnect"];
        self.connectionButtonStatus = 1;
    } else if (notification.name == CONNECTING_NOTIFICATION) {
        self.serverStatusView.text = @"Connecting...";
    } else if (notification.name == DISCONNECTED_NOTIFICATION) {
        self.serverStatusView.text = @"Disconnected";
    }
}

- (void)serverReconnectionStatusChangeNotification:(NSNotification *)notification
{
    if (notification.name == RECONNECTION_STARTED_NOTIFICATION) {
        [self.connectButton setTitle:@"Stop"];
        self.connectionButtonStatus = 1;
    } else if (notification.name == RECONNECTION_STOPPED_NOTIFICATION) {
        [self.connectButton setTitle:@"Connect"];
        self.connectionButtonStatus = 0;
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

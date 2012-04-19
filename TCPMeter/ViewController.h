//
//  ViewController.h
//  TCPMeter
//
//  Created by Karolis Stašaitis on 3/29/12.
//  Copyright (c) 2012 DevBridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "TCPClient.h"

@interface ViewController : UIViewController <UITextInputDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLatitudeView;
@property (weak, nonatomic) IBOutlet UILabel *locationLongitudeView;
@property (weak, nonatomic) IBOutlet UILabel *motionPitchView;
@property (weak, nonatomic) IBOutlet UILabel *motionRollView;
@property (weak, nonatomic) IBOutlet UILabel *motionYawView;
@property (weak, nonatomic) IBOutlet UIStepper * accuracyStepper;
@property (weak, nonatomic) IBOutlet UIStepper * rateStepper;
@property (weak, nonatomic) IBOutlet UILabel *accuracyView;
@property (weak, nonatomic) IBOutlet UILabel *rateView;
@property (weak, nonatomic) IBOutlet UILabel *serverStatusView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UITextField *hostnameTextView;
@property (weak, nonatomic) IBOutlet UITextField *portTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager  *motionManager;
@property (strong, nonatomic) TCPClient *client;

@property (strong, nonatomic) CMDeviceMotion *lastMotionValue;
@property (strong, nonatomic) CLLocation *lastLocationValue;
@property (assign, atomic) BOOL connectionButtonStatus;

- (IBAction)gpsAccuracyChanged:(id)sender;
- (void)switchGPSAccuracy:(int)value;

- (IBAction)refreshRateChanged:(id)sender;

@end

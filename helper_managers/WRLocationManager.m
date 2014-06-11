//
//  WRLocationManager.m
//
//	Copyright (c) 2014 Widget Revolt LLC.  All rights reserved
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import <CoreLocation/CoreLocation.h>
#import "WRLocationManager.h"

#import "WRLogging.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

static WRLocationManager* gSharedInstance_WRLocationManager = NULL;

//////////////////////////////////////////////////////////////////
@interface WRLocationManager()
{
	BOOL				m_WaitingForLocation;
	CLLocationManager*	m_LocationManager;

	CLLocation* m_OldLocation;
	CLLocation* m_NewLocation;
}

@property (nonatomic, retain) CLLocationManager*	m_LocationManager;
@property (nonatomic, assign) BOOL				m_WaitingForLocation;
@property (nonatomic, retain) CLLocation* m_OldLocation;
@property (nonatomic, retain) CLLocation* m_NewLocation;

@end

//////////////////////////////////////////////////////////////////
@implementation WRLocationManager



@synthesize m_LocationManager;
@synthesize m_WaitingForLocation;
@synthesize m_OldLocation,m_NewLocation;


//==============================================================
+ (WRLocationManager*) sharedManager
{
	static dispatch_once_t onceQueue;
	
    dispatch_once(&onceQueue, ^{
        gSharedInstance_WRLocationManager = [[WRLocationManager alloc] init];
    });
	
    return gSharedInstance_WRLocationManager;
}

//===========================================================
- (id) init
{
	if( (self = [super init]) )
	{
		self.m_LocationManager = NULL;
		self.m_OldLocation = NULL;
		self.m_NewLocation = NULL;
	}
	
	return self;
}

//===========================================================
- (void) dealloc
{

	self.m_LocationManager = NULL;
	self.m_OldLocation = NULL;
	self.m_NewLocation = NULL;


}

#pragma mark - location fixing

//===========================================================
- (int) startLocationFix
{
	// check framework available and if not perform callback indicating error
	if (![CLLocationManager class])
	{
		return eWRLocationMgr_locationServicesNotSupported;
	}
	
	if(m_WaitingForLocation)
	{
		return eWRLocationMgr_requestRunning;
	}
	
	// user disabled location?
	if(![CLLocationManager locationServicesEnabled])
	{
        
        // show an alert
		NSString* dlgTitle = NSLocalizedString(@"wrlocationmgr_unavailable_title", @"");
		NSString* dlgMessage = NSLocalizedString(@"wrlocationmgr_unavailable_msg", @"");
		[self messageBoxOK:dlgTitle message:dlgMessage];
        
		return eWRLocationMgr_locationServicesNotAvailable;
	}
	
	// ok - create a location manager
	if (!m_LocationManager)
    {
	    self.m_LocationManager = [[CLLocationManager alloc] init];
   	 	m_LocationManager.delegate = self;
 	}
	
 	m_WaitingForLocation = TRUE;
	
    [m_LocationManager startUpdatingLocation];

	return eWRLocationMgr_ok;
}

//===========================================================
- (void)locationManager:(CLLocationManager*) manager didUpdateToLocation:(CLLocation*) newLocation
		   fromLocation:(CLLocation*) oldLocation
{
	double lat = newLocation.coordinate.latitude;
	double lon = newLocation.coordinate.longitude;
	
	[m_LocationManager stopUpdatingLocation];
	m_WaitingForLocation = FALSE;
	
	// call the callback
	self.m_OldLocation = oldLocation;
	self.m_NewLocation = newLocation;

	// post a notification
	NSDictionary* infoDict = @{
		@"result":@"ok",
		@"errCode": @(eWRLocationMgr_ok),
		@"lat": @(lat),
		@"lon": @(lon)
	};
	[[NSNotificationCenter defaultCenter] postNotificationName:kWRLocationManagerNotification_lookupComplete
														object:self
													  userInfo:infoDict];



}

//===========================================================
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

	NSInteger errCode = [error code];
	WRDebugLog(@"Location update failed.  %@", error);
	
	// corelocatno returns kCLErrorLocationUnknown immediately if it can't get a fix so don't callback on that
	
	if(errCode == kCLErrorLocationUnknown) {
		return;
	}

	
	// kill old location info
	// maybe in the future you want to keep it but timestamp it?
	self.m_OldLocation = NULL;
	self.m_NewLocation = NULL;
	
	
	// call delegate
	NSDictionary* infoDict = @{
		@"result":@"err",
		@"errCode": @(errCode),
		@"lat": @(MAXFLOAT),
		@"lon": @(MAXFLOAT)
	};
	[[NSNotificationCenter defaultCenter] postNotificationName:kWRLocationManagerNotification_lookupComplete
														object:self
													  userInfo:infoDict];

	
	// stop updating
	[m_LocationManager stopUpdatingLocation];
	m_WaitingForLocation = FALSE;
    
    // notify the user
    NSString* dlgTitle = NSLocalizedString(@"wrlocationmgr_unavailable_title", @"");
    NSString* dlgMessage = NSLocalizedString(@"wrlocationmgr_unavailable_msg", @"");
    [self messageBoxOK:dlgTitle message:dlgMessage];
}

//===========================================================
- (CLLocation*) getNewLocation
{
	return m_NewLocation;
}

#pragma mark - Error message

//=======================================================================================
- (void) messageBoxOK:(NSString*)title message:(NSString*)message
{
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:NULL
											  cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
	[alertView show];

}

@end

//
//  AnalyticsHelper.m
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


#import "AnalyticsHelper.h"

#import "WRLogging.h"


#if USE_GOOGLE
#import "GAI.h"
#endif


#if USE_FLURRY
#import "Flurry.h"
#endif

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif



#ifndef ANDROID



static AnalyticsHelper* gSharedInstance_AnalyticsHelper = NULL;

/////////////////////////////////////////////////////////////////////
@interface AnalyticsHelper()

@property (nonatomic, strong) NSString* mFlurryAPIKey;
@property (nonatomic, strong) NSString* mGoogleAPIKey;

@end

/////////////////////////////////////////////////////////////////////
@implementation AnalyticsHelper

//==============================================================
+ (AnalyticsHelper*) sharedManager
{
	static dispatch_once_t onceQueue;
	
    dispatch_once(&onceQueue, ^{
        gSharedInstance_AnalyticsHelper = [[AnalyticsHelper alloc] init];
    });
	
    return gSharedInstance_AnalyticsHelper;
}

//===========================================================
- (id) init
{
	if( (self = [super init]) )
	{
		self.mFlurryAPIKey = NULL;
		self.mGoogleAPIKey = NULL;
	
		// get the data once to make sure it exists
		//[self startup];
	}
	
	return self;
}


//===========================================================
- (void) startupWithAPIKeys:(NSDictionary*)apiKeys
{
	WRDebugLog(@"analytics startup");
	
	
	
	// register with the notification manager for the events we care about
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillResume:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillSuspend:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillSuspend:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
	
#if USE_GOOGLE

	NSString* googleAPIKey = apiKeys[@"google"];
	if(googleAPIKey) {
		self.mGoogleAPIKey = googleAPIKey;
	}
	
	
	// and start the tracker
	[self startTracker:_mGoogleAPIKey];
	

	//add an uncaught exception handler
	[GAI sharedInstance].trackUncaughtExceptions = YES;
#endif
	
#if USE_FLURRY

	NSString* flurryKey = apiKeys[@"flurry"];
	if(flurryKey) {
		self.mFlurryAPIKey = flurryKey;
	}
	

	//[Flurry setCrashReportingEnabled:YES];
	
#if DEBUG
	[Flurry setDebugLogEnabled:TRUE];
	[Flurry setLogLevel:FlurryLogLevelDebug];
	
	[Flurry setAppVersion:@"666"];//<-- indicates the debug version so we don't pollute flurry versions
#endif
	
	
	[Flurry startSession:_mFlurryAPIKey];
	
	
	
#endif
	
	
}


//===========================================================
- (void) onAppWillResume:(NSNotification*)notif
{
	WRDebugLog(@"analytics resume");

#if USE_GOOGLE
	[self startTracker:_mGoogleAPIKey];
#endif
}

//===========================================================
- (void) onAppWillSuspend:(NSNotification*)notif
{
	WRDebugLog(@"analytics suspend");

#if USE_GOOGLE
	[self stopTracker];
#endif
}
//===========================================================
// this needs to be added to the following:
//	applicationDidBecomeActive:
//
- (void) startTracker:(NSString*)trackerId
{
#if USE_GOOGLE
	
#if DEBUG
	[GAI sharedInstance].debug = TRUE;
#endif
	[GAI sharedInstance].dispatchInterval = 30.0f;	// 20 second dispatch interface
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackerId];
	tracker.anonymize = TRUE;
	
	// set dimension 1 as our app version
	NSString* appVersion = [WRUtils getAppVersionInfoStd];
	[tracker setCustom:1 dimension:appVersion];
	
#endif
	
	// send a start event
	///[self trackEvent:@"" action:@"" label:@"" value:0];
}
//===========================================================
- (void) stopTracker
{

	
#if USE_GOOGLE
	// dispatch whats left
	[[GAI sharedInstance] dispatch];

	
	///[[GANTracker sharedTracker] stopTracker];
#endif
}
//===========================================================
- (void) pauseTracker
{
}
//===========================================================
- (void) resumeTracker
{
}
//===========================================================
- (void) addUserId:(NSString*)userId gender:(NSString*)gender age:(int)age
{
#if USE_FLURRY
	NSString* lGender = [gender lowercaseString];
	
	if([lGender isEqualToString:@"male"])
	{
		lGender = @"m";
	}
	else if([lGender isEqualToString:@"female"])
	{
		lGender = @"f";
	}
	
	if([lGender isEqualToString:@"m"] || [lGender isEqualToString:@"f"]) {
		[Flurry setGender:gender];
	}
	if(age > 0 && age < 150) {
		[Flurry setAge:age];
	}
	[Flurry setUserID:userId];
#endif
}
//===========================================================
- (void) trackPage:(NSString*)pageId
{
	BOOL ok = YES;
	#pragma unused(ok)
	
#if USE_GOOGLE
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	ok = [tracker sendView:pageId];
	
	if(!ok) {
		WRErrorLog(@"Error in trackPage");
	}
#endif
	
#if USE_FLURRY
	NSString* eventName = [NSString stringWithFormat:@"page.%@", pageId];
	
	[Flurry logEvent:eventName];
#endif
	
	WRDebugLog(@"[analytics.trackpage] pageId:%@, response:%d", pageId, ok);
	
}
//===========================================================
- (void) trackEvent:(NSString*)category action:(NSString*)action
{
	[self trackEvent:category action:action label:@"" value:0];
}
//===========================================================
- (void) trackEvent:(NSString*)category action:(NSString*)action label:(NSString*)label value:(int)value
{
#if USE_GOOGLE
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	BOOL ok = [tracker sendEventWithCategory:category
								  withAction:action
								   withLabel:label
								   withValue:[NSNumber numberWithInt:value]];
	
	WRDebugLog(@"[analytics.trackevent] category:%@, action:%@, label:%@, value:%d, response:%d", category, action, label, value, ok);
	
	if(!ok) {
		WRErrorLog(@"Error in trackEvent");
	}
#endif
	
#if 0
	
	NSString* eventName = action;
	if(![NSString isEmptyString:label])
	{
		NSDictionary*  paramDict = @{
									 @"label": label
									 };
		[Flurry logEvent:eventName withParameters:paramDict];
	}
	else
	{
		[Flurry logEvent:eventName];
	}
	
#endif
	
	
}
//===========================================================
- (void) trackEventEx:(NSString*)event
{
#if USE_FLURRY
	NSString* eventName = event;
	
	[Flurry logEvent:eventName];
#endif
	
	WRDebugLog(@"[analytics.trackevent] event: %@", event);
}
//===========================================================
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name param1:(NSString*)param1
{
	NSString* eventName = event;
	
	// fix for crashes
	NSString* localParam = @"";
	if(param1 != NULL) {
		localParam = param1;
	}
	
	NSDictionary* paramDict = @{
								param1Name: localParam
								};
	
#if USE_FLURRY
	
	
	[Flurry logEvent:eventName withParameters:paramDict];
#endif
	
	WRDebugLog(@"[analytics.trackevent] event: %@, params: %@", event, paramDict);
}
//===========================================================
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name param1:(NSString*)param1 param2Name:(NSString*)param2Name param2:(NSString*)param2
{
	
	NSString* eventName = event;
	
	NSDictionary* paramDict = @{
								param1Name: param1,
								param2Name: param2
								};
#if USE_FLURRY
	[Flurry logEvent:eventName withParameters:paramDict];
#endif
	
	WRDebugLog(@"[analytics.trackevent] event: %@, params: %@", event, paramDict);
}

//===========================================================
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name intParam1:(int)intParam1 param2Name:(NSString*)param2Name param2:(NSString*)param2
{
	
	NSString* eventName = event;
	
	NSDictionary* paramDict = @{
								param1Name: @(intParam1),
								param2Name: param2
								};
#if USE_FLURRY
	[Flurry logEvent:eventName withParameters:paramDict];
#endif
	
	WRDebugLog(@"[analytics.trackevent] event: %@, params: %@", event, paramDict);
}

//===========================================================
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name intParam1:(int)intParam1
{
	
	NSString* eventName = event;
	
	NSDictionary* paramDict = @{
								param1Name: @(intParam1)
								};
#if USE_FLURRY
	[Flurry logEvent:eventName withParameters:paramDict];
#endif
	
	WRDebugLog(@"[analytics.trackevent] event: %@, params: %@", event, paramDict);
}

//===========================================================
- (void) trackCaughtException:(NSString*)eventErr errParam:(NSString*)errParam
{
	[self trackEventEx:eventErr param1Name:@"err" param1:errParam];
}
//===========================================================
- (void) trackPurchase:(NSString*)sku name:(NSString*)name price:(float)price quantity:(int)quantity transactionId:(NSString*)transactionId
{
	
	
	float revenue = price * (float) quantity;
	
#if USE_GOOGLE
	
	const float kGoogleMicros = 1000000;
	GAITransaction* transaction = [GAITransaction transactionWithId:transactionId
													withAffiliation:@"itms_inapp_store"];
	transaction.taxMicros = 0;
	transaction.shippingMicros = 0;
	transaction.revenueMicros = (int64_t) (revenue * kGoogleMicros);
	
	
	// add an item to the transaction
	[transaction addItemWithCode:sku
							name:name
						category:nil
					 priceMicros:(int64_t) (price * kGoogleMicros)
						quantity:quantity];
	
	// send it
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	BOOL ok = [tracker sendTransaction:transaction]; // Send the transaction.
	
	WRDebugLog(@"[analytics.trackpurchase] sku:%@, transactionId:%@, quantity:%d, ok?%c", sku, transactionId, quantity, ok);
	
	if(!ok) {
		WRErrorLog(@"Error in trackPurchase");
	}
#endif
	
#if USE_FLURRY
	NSString* eventName = @"in_app_purchase";
	
	NSDictionary* paramDict = @{
								@"sku": sku,
								@"revenue": @(revenue)
								};
	
	[Flurry logEvent:eventName withParameters:paramDict];
#endif
}

@end

#endif	//!ANDROID

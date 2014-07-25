//
//  WRInstallTrackerHelper.m
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

#import "WRInstallTrackerHelper.h"

#ifndef ANDROID
#define TAPSTREAM	1
#endif

#if TAPSTREAM
#import "TSTapstream.h"
#endif


#define kInstallTracker_installEvent	@"app_install"

#define kPref_installTrackerInstall		@"wr_tapstream_install_tag"


//////////////////////////////////////////////////////////////////////
@interface WRInstallTrackerHelper()

@property (nonatomic, strong) NSString* mAppName;
@property (nonatomic, strong) NSString* mUserId;

@end

//////////////////////////////////////////////////////////////////////
@implementation WRInstallTrackerHelper

//==============================================================
+ (WRInstallTrackerHelper*) sharedManager
{
	static dispatch_once_t onceQueue;
	static WRInstallTrackerHelper* _sharedClient = nil;
    dispatch_once(&onceQueue, ^{
        _sharedClient = [[WRInstallTrackerHelper alloc] init];
    });
	
    return _sharedClient;
}

//===========================================================
- (void) registerWithAccountName:(NSString*)accountName secret:(NSString*)secret appname:(NSString*)appname userId:(NSString*)userId
{
	self.mAppName = appname;
	self.mUserId = userId;

#if TAPSTREAM
	TSConfig* config = [TSConfig configWithDefaults];
	
	
	config.idfa = [WRSystemInfo getAdvertiserId];
	
	[TSTapstream createWithAccountName:accountName developerSecret:secret config:config];
#endif
	
	// if we haven't been installed, then record that now
	[self trackEvent:kInstallTracker_installEvent oneTimeOnly:TRUE];
}

//===========================================================
- (void) trackEvent:(NSString*)eventName oneTimeOnly:(BOOL)oneTimeOnly
{

#if TAPSTREAM
	
	TSTapstream* tracker = [TSTapstream instance];
	
	TSEvent* e = [TSEvent eventWithName:eventName oneTimeOnly:oneTimeOnly];
	[e addValue:_mAppName forKey:@"appname"];
	[e addValue:_mUserId forKey:@"user_id"];
	[tracker fireEvent:e];
	
#endif
}

//===========================================================
- (void) trackEvent:(NSString*)eventName key1:(NSString*)key1 value1:(NSString*)value1 oneTimeOnly:(BOOL)oneTimeOnly
{
	
#if TAPSTREAM
	
	TSTapstream* tracker = [TSTapstream instance];
	
	TSEvent* e = [TSEvent eventWithName:eventName oneTimeOnly:oneTimeOnly];
	[e addValue:_mAppName forKey:@"appname"];
	[e addValue:_mUserId forKey:@"user_id"];
	[e addValue:key1 forKey:value1];
	[tracker fireEvent:e];
	
#endif
}

//===========================================================
- (void) trackPurchase:(NSString*)eventName productId:(NSString*)productId price:(double)price
{

//TAPSTREAM handles this automatically now
#if 0
	
	TSTapstream* tracker = [TSTapstream instance];
	
	TSEvent* e = [TSEvent eventWithName:eventName oneTimeOnly:FALSE];
	[e addValue:productId forKey:@"product_id"];
	[e addValue:@(price) forKey:@"price"];
	[e addValue:_mAppName forKey:@"appname"];
	[e addValue:_mUserId forKey:@"user_id"];
	[tracker fireEvent:e];
	
#endif
}

//===========================================================
- (void) getConversionData:(WRInstallTrackerConversionResult)callback
{

#if TAPSTREAM
	TSTapstream* tracker = [TSTapstream instance];
	[tracker getConversionData:^(NSData *jsonInfo) {
	
		WRDebugLog(@"WRInstallTrackerHelper: complete getConversionData");
	
		if(jsonInfo == nil)
		{
			WRDebugLog(@"WRInstallTrackerHelper: getConversionData got no data");
		
			// No conversion data available
			callback(eInstallTrackerResultErr_err, NULL);
			return;	//EXIT
		}
		
		NSError* error;
		NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonInfo options:kNilOptions error:&error];
		if(!json) {
			WRErrorLog(@"Error parsing tapstream conversion info: %@", error);
			callback(eInstallTrackerResultErr_err, NULL);
			return; //EXIT
		}
		
		// get the first element of the hits array - safely
		if(json[@"hits"] && [json[@"hits"] count] > 0)
		{
			NSDictionary* hit = json[@"hits"][0];
			callback(eInstallTrackerResultErr_ok, hit);
			return; //EXIT OK
		}
		else
		{
			WRDebugLog(@"WRInstallTrackerHelper: getConversionData got no hit data");
		
			callback(eInstallTrackerResultErr_unattributed, NULL);
		}

	}];
	
#else
	
	//unsupported
	callback(eInstallTrackerResultErr_err, NULL);

#endif
}


@end

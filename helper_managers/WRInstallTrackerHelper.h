//
//  WRInstallTrackerHelper.h
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

#import <Foundation/Foundation.h>


#define kInstallTracker_purchaseEvent	@"iap_purchase"

// for personal tracking
#define kPref_installTracker_trackerId	@"installtracker.tracker_id"
#define kPref_installTracker_trackerName	@"installtracker.tracker_name"
#define kPref_installTracker_referrer	@"installtracker.tracker_referrer"
#define kPref_installTracker_referrerIp	@"installtracker.tracker_referrer_ip"

typedef enum
{
	eInstallTrackerResultErr_ok = 0,
	eInstallTrackerResultErr_err = -1,		//generic error
	eInstallTrackerResultErr_unattributed = -2		//no attribution for user
} EnumInstallTrackerResultErr;

typedef void(^WRInstallTrackerConversionResult)(EnumInstallTrackerResultErr err, NSDictionary* result);

@interface WRInstallTrackerHelper : NSObject

+ (WRInstallTrackerHelper*) sharedManager;

- (void) registerWithAccountName:(NSString*)accountName secret:(NSString*)secret appname:(NSString*)appname userId:(NSString*)userId;
- (void) trackEvent:(NSString*)eventName oneTimeOnly:(BOOL)oneTimeOnly;
- (void) trackEvent:(NSString*)eventName key1:(NSString*)key1 value1:(NSString*)value1 oneTimeOnly:(BOOL)oneTimeOnly;
- (void) trackPurchase:(NSString*)eventName productId:(NSString*)productId price:(double)price;

- (void) getConversionData:(WRInstallTrackerConversionResult)callback;


@end

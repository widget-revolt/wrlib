//
//  AnalyticsHelper.h
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

#define USE_FLURRY	1
#define USE_GOOGLE	0

@interface AnalyticsHelper : NSObject


+ (AnalyticsHelper*) sharedManager;

	/// Pass a dictionary of API keys.  Use the following
	/// @"flurry" = flurry api key
	/// @"google" = google api key
- (void) startupWithAPIKeys:(NSDictionary*)apiKeys;

- (void) startTracker:(NSString*)trackerId;
- (void) stopTracker;

- (void) addUserId:(NSString*)userId gender:(NSString*)gender age:(int)age;

/// tracks views (aka "pages")
- (void) trackPage:(NSString*)pageId;

/// tracks events


// Flurry /Localytics, etc
- (void) trackEventEx:(NSString*)event;
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name param1:(NSString*)param1;
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name param1:(NSString*)param1 param2Name:(NSString*)param2Name param2:(NSString*)param2;

- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name intParam1:(int)intParam1;
- (void) trackEventEx:(NSString*)event param1Name:(NSString*)param1Name intParam1:(int)intParam1 param2Name:(NSString*)param2Name param2:(NSString*)param2;

// commerce
- (void) trackPurchase:(NSString*)sku name:(NSString*)name price:(float)price quantity:(int)quantity transactionId:(NSString*)transactionId;

// errors - these are just events with an error str param
- (void) trackCaughtException:(NSString*)eventErr errParam:(NSString*)errParam;

@end

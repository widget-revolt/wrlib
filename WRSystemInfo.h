//
//  WRSystemInfo.h
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

@interface WRSystemInfo : NSObject

//--Networking info
+ (NSString*) getIPAddress;

//--Advertiser info
+ (BOOL) isAdTrackingEnabled;
+ (NSString*) getAdvertiserId;	// returns empty string if not available
+ (NSString*) getVendorId;

//--carrier info
// keys= carrier, mcc, mnc
+ (NSDictionary*) getCarrierInfo;


//--DEPRECATED - DO NOT PERFORM PROPERLY on iOS7.
// iOS7 always returns the same mac address so these methods don't work any more
+ (NSString*) getPrimaryMACAddress;
+ (NSString*) getPrimaryMACAddressClean;	// returns with no colons
+ (NSString*) getODIN; // this is the SHA-1 of the wifi mac address

@end

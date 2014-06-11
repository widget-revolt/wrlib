//
//  WRSystemInfo.m
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

#import "WRSystemInfo.h"
#import "WRUtils.h"
#import "WRLogging.h"

//iOS only
#ifndef ANDROID


#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6/* Ethernet CSMACD */
#endif


#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif


@implementation WRSystemInfo

//===========================================================
// thanks e.sadun
// returns mac address of wifi adapter..
// Except on iOS7 this now returns the same thing always
+ (NSString*) getPrimaryMACAddress
{
    
	int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0)
    {
        NSLog(@"Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
    {
        NSLog(@"Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char*)malloc(len)) == NULL)
    {
        NSLog(@"Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        NSLog(@"Error: sysctl, take 2\n");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring =
	[NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
	 *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

//===========================================================
// returns a mac address with no colons
+ (NSString*) getPrimaryMACAddressClean
{
	NSString* macAddr = [WRSystemInfo getPrimaryMACAddress];
	NSArray* array = [macAddr componentsSeparatedByString:@":"];
	macAddr = [array componentsJoinedByString:@""];
	
	return macAddr;
}

//===========================================================
+ (NSString*) getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
																																   //NSLog(@"NAME: \"%@\" addr: %@", name, addr);
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else if([name isEqualToString:@"pdp_ip0"]) {
                    // Interface is the cell connection on the iPhone
                    cellAddress = addr;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}


#pragma mark - Advertiser-ish info

//===========================================================
+ (NSString*) getODIN
{
	NSString* retStr = @"";
	
    NSString* macAddr = [WRSystemInfo getPrimaryMACAddress];
    if(macAddr)
	{
		retStr = [WRUtils sha1:macAddr];
    }
	
    return retStr;
}
//===========================================================
+ (BOOL) isAdTrackingEnabled
{
	if(NSClassFromString(@"ASIdentifierManager"))
	{
		return([ASIdentifierManager sharedManager].advertisingTrackingEnabled);
	}
	
	return FALSE;
}
//===========================================================
+ (NSString*) getAdvertiserId
{
	// since this uses a dynamic conversion it will just return an empty string/null for advertiserID
	NSString* advertiserID = NULL;
	if(NSClassFromString(@"ASIdentifierManager"))
	{
		advertiserID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	}
	
	if(!advertiserID) {
		advertiserID = @"";
	}
	
	return advertiserID;
}

//===========================================================
+ (NSString*) getVendorId
{
	NSString* vendorId = NULL;
	@try {
		vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
	}
	@catch(...) {
		WRErrorLog(@"error getting vendor id");
	}
	
	if(!vendorId) {
		vendorId = @"";
	}
	
	return vendorId;
}

//===========================================================
+ (CTTelephonyNetworkInfo*) getTelephonyInfo
{
	CTTelephonyNetworkInfo* tni = NULL;
	
	if (NSClassFromString(@"CTTelephonyNetworkInfo") == NULL)
	{
		WRDebugLog(@"telephony info unavailable");
		return NULL;
	}
	
	// Wrap in try/catch in case we fail due to unavailability
	@try
	{
		tni = [[CTTelephonyNetworkInfo alloc] init];
		
	}
	@catch(...)
	{
		WRErrorLog(@"telephony info unavailable");
		tni = NULL;
	}
	
	return tni;
}

//===========================================================
+ (NSDictionary*) getCarrierInfo
{
	NSString* carrierName = @"";
	NSString* mcc = @"";
	NSString* mnc = @"";
	
	CTTelephonyNetworkInfo* telephonyInfo = [WRSystemInfo getTelephonyInfo];
	if(telephonyInfo)
	{
		CTCarrier* ctCarrier = [telephonyInfo subscriberCellularProvider];
		if(!ctCarrier) {
			WRErrorLog(@"CTCarrier unavailable");
		}
		else
		{
			carrierName = ctCarrier.carrierName;
			mcc = ctCarrier.mobileCountryCode;
			mcc = ctCarrier.mobileNetworkCode;
		}
		
	}
	
	NSDictionary* retDict = @{
						   @"carrier": carrierName,
		 @"mcc": mcc,
		 @"mnc": mnc
		 };
	
	return retDict;
	
}


@end

#endif //!ANDROID
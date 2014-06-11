//
//  WRUUID.m
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


#import "WRUUID.h"
#import "WRUtils.h"

//iOS only
#ifndef ANDROID

#import "NSString+WRAdditions.h"
#import <CommonCrypto/CommonDigest.h>


#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

///////////////////////////////////////
@implementation WRUUID


//===========================================================
+ (void) createUUIDWithSalt:(NSString*)salt
{
	// if we haev a uuid or hash, return
	NSString* uuid = [self getAppUUID];
	NSString* hash = [self getAppUUIDHash];
	if(![NSString isEmptyString:uuid] && ![NSString isEmptyString:hash])
	{
		return;
	}

	NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
	
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef cfstr = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    NSString* curUUID = (__bridge NSString*)cfstr;
    
    // create the hash of the uuid
	NSString* saltedString = [NSString stringWithFormat:@"%@%@%@", salt, curUUID, salt];
	NSString* uuidHash = [WRUtils sha256:saltedString];

    
    // store both
    [SSKeychain setPassword:curUUID forService:appBundleID account:kWRUUID_key_uuid];
    [SSKeychain setPassword:uuidHash forService:appBundleID account:kWRUUID_key_uuidhash];
}

//===========================================================
+ (NSString*) getAppUUID
{
	NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
	
    NSString* curUUID = [SSKeychain passwordForService:appBundleID account:kWRUUID_key_uuid];
    return curUUID;
}

//===========================================================
+ (NSString*) getAppUUIDHash
{
	NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString* curUUIDHash = [SSKeychain passwordForService:appBundleID account:kWRUUID_key_uuidhash];
    return curUUIDHash;
}


@end

#endif

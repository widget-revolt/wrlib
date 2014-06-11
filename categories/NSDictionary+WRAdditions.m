//
//  NSDictionary+WRAdditions.m
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



#import "NSDictionary+WRAdditions.h"

#import "NSString+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif


@implementation NSDictionary(WRAdditions)


//===========================================================
// takes a dictionary (like one retrieved from a plist) and returns a completely mutable copy of everything within
+ (NSMutableDictionary *) dictionaryByDeepCopying:(NSDictionary*)inDict
{
	CFPropertyListRef plist = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFPropertyListRef)(inDict), kCFPropertyListMutableContainersAndLeaves);
	
	// we check if it is the correct type and only return it if it is
	if ([(__bridge id)plist isKindOfClass:[NSMutableDictionary class]])
	{
		NSMutableDictionary* retObj = (__bridge NSMutableDictionary *)plist;
		return retObj;//EXIT
	}
	else
	{
		// clean up ref
		if(plist) {
			CFRelease(plist);
		}
		return nil;
	}
}

//===========================================================
// modified from here: http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
+ (NSMutableDictionary*) dictionaryFromURLQueryComponents:(NSURL*)url
{
	NSMutableDictionary* queryComponents = [NSMutableDictionary dictionary];
	NSString* queryStr = [url query];
    for(NSString* keyValuePairString in [queryStr componentsSeparatedByString:@"&"])
    {
        NSArray* keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) {
			continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
		}
        NSString* key = [[keyValuePairArray objectAtIndex:0] urlDecode];
        NSString* value = [[keyValuePairArray objectAtIndex:1] urlDecode];
        NSMutableArray *results = [queryComponents objectForKey:key]; // URL spec says that multiple values are allowed per key
        if(!results) // First object
        {
            results = [NSMutableArray arrayWithCapacity:1];
            [queryComponents setObject:results forKey:key];
        }
        [results addObject:value];
    }
    return queryComponents;
}

//===========================================================
- (id) getRequiredObjectForKey:(NSString*)key
{
	id retObj = [self objectForKey:key];
	NSAssert1(retObj != NULL, @"Required key (%@) not found.", key);
	
	return retObj;
}

//===========================================================
- (id) vectorRangeLookupForValue:(float)lookupValue
{
//	NSArray* sortedKeys = [self keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//
//		if ([obj1 floatValue] > [obj2 floatValue]) {
//			return (NSComparisonResult)NSOrderedDescending;
//		}
//		
//		if ([obj1 floatValue] < [obj2 floatValue]) {
//			return (NSComparisonResult)NSOrderedAscending;
//		}
//		return (NSComparisonResult)NSOrderedSame;
//	}];

	NSArray* unsortedKeys = [self allKeys];
	
	// sort the keys by vaul
	NSArray* sortedKeys = [unsortedKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 floatValue] > [obj2 floatValue]) {
			return (NSComparisonResult)NSOrderedDescending;
		}

		if ([obj1 floatValue] < [obj2 floatValue]) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	}];
	
	// find insert index for lookup value.  That tells us which object we want
	NSUInteger ix = [sortedKeys indexOfObject:@(lookupValue)
								inSortedRange:NSMakeRange(0,[sortedKeys count])
									  options:NSBinarySearchingInsertionIndex
							  usingComparator:^NSComparisonResult(id obj1, id obj2)
							  {
								  if ([obj1 floatValue] > [obj2 floatValue]) {
									  return (NSComparisonResult)NSOrderedDescending;
								  }
								  
								  if ([obj1 floatValue] < [obj2 floatValue]) {
									  return (NSComparisonResult)NSOrderedAscending;
								  }
								  return (NSComparisonResult)NSOrderedAscending;	//<== This ensures that values == to base are marked as being above
							}];
	
	
	int lookupIndex = (int) (ix - 1); // safe cast...we shouldn't have a range greater than 32 bit
	
	// this would be undefined since we are technically *before* our range starts
	if(lookupIndex < 0)
	{
		NSAssert(ix >= 0, @"Out-of-bound range lookup");
		return NULL;
	}
	
	id key = sortedKeys[lookupIndex];
	id retObj = self[key];
	
	return retObj;
	
}

//===========================================================
// TODO: Move this to a proper testing framework
+ (void) testNSDictionaryWRAdditions
{
	NSDictionary* lookup = @{
							 
							 @(2): @(100),
							 @(50): @(2000),
							 @(75): @(300)
							 
							 };
	
	NSNumber* lookupVal;
	float lookupKey;
	float flookupVal;
	
	lookupKey = 22;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
	flookupVal = [lookupVal intValue];
	NSAssert(flookupVal == 100, @"test failed");
	
	lookupKey = 55;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
	flookupVal = [lookupVal intValue];
	NSAssert(flookupVal == 2000, @"test failed");
	
	
	lookupKey = 76;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
	flookupVal = [lookupVal intValue];
	NSAssert(flookupVal == 300, @"test failed");
	
	// boundary tests
	lookupKey = 75;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
	flookupVal = [lookupVal intValue];
	NSAssert(flookupVal == 300, @"test failed");
	
	lookupKey = 2;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
	flookupVal = [lookupVal intValue];
	NSAssert(flookupVal == 100, @"test failed");
	
	
//	lookupKey = 0;
//	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
//	WRDebugLog(@"Found key=%3.2f, val=%@", lookupKey, lookupVal);
//	flookupVal = [lookupVal intValue];
//	NSAssert(flookupVal == 100, @"test failed");
	
	lookupKey = -1;
	lookupVal = (NSNumber*) [lookup vectorRangeLookupForValue:lookupKey];
	NSAssert(lookupVal == NULL, @"test failed");
}


@end

//
//  NSJSONSerialization+WRAdditions.m
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



#import "NSJSONSerialization+WRAdditions.h"

#import "WRLogging.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSJSONSerialization (WRAdditions)

//===========================================================
+ (NSString*) stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt
{
	NSError* error;
	NSData* data = [NSJSONSerialization dataWithJSONObject:obj options:opt error:&error];
	if(!data) {
		WRErrorLog(@"An error occurred creating json: %@", error);
		return NULL;
	}
	
	// convert to string
	NSString* retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return retStr;
}

//===========================================================
+ (id)JSONObjectWithString:(NSString *)jsonStr options:(NSJSONReadingOptions)opt
{
	NSData* jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];

	NSError* error;
	id parsedObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	if(!parsedObj) {
		WRErrorLog(@"An error occurred parsing json: %@", error);
		return NULL;
	}
	
	return parsedObj;
}

@end

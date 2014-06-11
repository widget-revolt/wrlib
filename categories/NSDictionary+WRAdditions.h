//
//  NSDictionary+WRAdditions.h
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


@interface NSDictionary(WRAdditions)

/// creates a mutable dictionary (deep) from dictionary
+ (NSMutableDictionary *) dictionaryByDeepCopying:(NSDictionary*)inDict;

/// creates a mutable dictionary from query components
///  Note that the result data in the key data pairs is returned as an array
+ (NSMutableDictionary*) dictionaryFromURLQueryComponents:(NSURL*)url;

/// same as get object but throws an assert if object not available
- (id) getRequiredObjectForKey:(NSString*)key;

/// performs an Excel-like vector lookup.  It assumes that the keys are either NSNumber or NSString-based numbers (if you are loading from JSON) since it uses [xxxx floatValue] to compare key values for the range.
- (id) vectorRangeLookupForValue:(float)lookupValue;


// TODO: Move this to a proper testing framework
+ (void) testNSDictionaryWRAdditions;


@end


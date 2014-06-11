//
//  NSArray+WRAdditions.m
//
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



#import "NSArray+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSArray (WRAdditions)
- (id) randomElement
{
	NSUInteger myCount = [self count];
	if (myCount)
		return [self objectAtIndex:arc4random_uniform((unsigned int) myCount)];
	else
		return nil;
	
}

@end

@implementation NSMutableArray (WRAdditions)

- (void) shuffle
{
	NSUInteger len = [self count];
	for (uint i = 0; i < len; ++i)
	{
		// Select a random element between i and end of array to swap with.
		NSUInteger nElements = len - i;
		int n = arc4random_uniform((unsigned int)nElements) + i;
		[self exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}




@end

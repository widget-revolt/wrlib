//
//  UITextField+WRAdditions.m
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



#import "UITextField+WRAdditions.h"
#import "NSString+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation UITextField (WRAdditions)

#define kAlphaNumeric @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\'_- \\b"

//===========================================================
+ (NSCharacterSet*) textFieldNumericCharacters
{
	// includes \b for backspace
	return([NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"]);
}
//===========================================================
+ (NSCharacterSet*) textFieldAlphaNumericCharacters
{
	NSCharacterSet* alphaNumericSet = [NSCharacterSet characterSetWithCharactersInString:kAlphaNumeric];

	
	return alphaNumericSet;
}

//===========================================================
+ (BOOL) allowableCharForField:(UITextField*)textField range:(NSRange)range replacementStr:(NSString*)textEntered characterSet:(NSCharacterSet*)characterSet
{
	if([NSString isEmptyString:textEntered]) {
		return TRUE;
	}

	unichar c = [textEntered characterAtIndex:[textEntered length] - 1];
	if (![characterSet characterIsMember:c]) {
		return FALSE;
	}
	
	return TRUE;
}
//===========================================================
+ (BOOL) allowableLenForField:(UITextField*)textField range:(NSRange)range replacementStr:(NSString*)textEntered maxLength:(int)maxLength
{
	NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [textEntered length];
    NSUInteger rangeLength = range.length;
	
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
	
    BOOL returnKey = [textEntered rangeOfString: @"\n"].location != NSNotFound;
	
    return newLength <= maxLength || returnKey;
}

@end

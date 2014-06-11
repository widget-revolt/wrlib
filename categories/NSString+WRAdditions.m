// NSString+WRAdditions.m
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



#import "NSString+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSString (WRAdditions)

//===========================================================
// http://stackoverflow.com/questions/2590545/urlencoding-a-string-with-objective-c
- (NSString*) urlEncode
{
	CFStringRef escapeChars = (CFStringRef) @":/?#[]@!$&’()*+,;=";
	NSString* encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
													NULL, 
													(CFStringRef) self, 
													NULL, 
													escapeChars, 
													kCFStringEncodingUTF8));
	return encodedString;

}
//===========================================================
+ (NSString*) urlParamStrFromDict:(NSDictionary*)paramDict
{
	NSString* retStr = @"";
	NSArray* keys = [paramDict allKeys];
	NSMutableArray* fullList = [NSMutableArray array];
	
	for(NSString* key in keys)
	{
		NSString* val = [paramDict objectForKey:key];
		
		// NOTE: this won't provide any string coersion
		val = [val urlEncode];
		
		val = [NSString stringWithFormat:@"%@=%@", key, val];
		[fullList addObject:val];
	}
	
	// convert the full list into a string
	retStr = [fullList componentsJoinedByString:@"&"];
	
	return retStr;
}
//===========================================================
// from here: http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
- (NSString*) urlDecode
{
    NSString* result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}
//===========================================================
- (BOOL) isEmptyOrWhitespace
{
	return ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0);
}

//===========================================================
- (BOOL) isInteger
{
	return([[NSScanner scannerWithString:self] scanInt:nil]);
}
//===============================================================================
// Use this to test for both null and empty
+ (BOOL)isEmptyString:(NSString *)string
// Returns YES if the string is nil or equal to @""
{
    // Note that [string length] == 0 can be false when [string isEqualToString:@""] is true, because these are Unicode strings.
    return (string == nil || [string isEmptyOrWhitespace]);
}


//===========================================================
- (NSString*) stripQuotes
{
	NSMutableString* theMutableString = [[NSMutableString alloc] initWithString:self] ;

	[theMutableString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:(NSRange){0,[theMutableString length]}];
	[theMutableString replaceOccurrencesOfString:@"\'" withString:@"" options:NSCaseInsensitiveSearch range:(NSRange){0,[theMutableString length]}];
	
	NSString* retString = [NSString stringWithString:theMutableString];

	return retString;

}


//===============================================================================
+ (NSString*) stringFromFile:(NSString*)fileName withExtension:(NSString*)extension
{
	NSString* retStr = NULL;
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];  
	if (filePath) 
	{ 
		NSStringEncoding encoding;
		NSError* err = NULL;
		retStr = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&err];    
	}
	
	return retStr;
}


//===============================================================================
//General search-and-replace mechanism to convert text between the given delimeters.  
//Pass in a dictionary with the keys of "from" strings, and the values of what to convert them to.  
//If not found in the dictionary,  the text will just be removed.  
//If the dictionary passed in is nil, then the string between the delimeters will put in the place of the whole range; 
//this could be used to just strip out the delimeters.
//
//Requires -[NSString rangeFromString:toString:options:range:].


- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2
	fromDictionary:(NSDictionary *)inDict
	options:(unsigned)inMask 
	range:(NSRange)inSearchRange
{
	NSRange range = inSearchRange;	// We'll increment this
	NSUInteger startLength = [inString1 length];
	NSUInteger delimLength = startLength + [inString2 length];
	NSMutableString *buf = [NSMutableString string];

	NSRange beforeSearchRange = NSMakeRange(0,inSearchRange.location);
	[buf appendString:[self substringWithRange:beforeSearchRange]];

	// Now loop through; looking.
	while (range.length != 0)
	{
		NSRange foundRange = [self rangeFromString:inString1 toString:inString2 options:inMask range:range];
		if (foundRange.location != NSNotFound)
		{
			// First, append what was the search range and the found range -- before match -- to output
			{
				NSRange beforeRange = NSMakeRange(range.location, foundRange.location - range.location);
				NSString *before = [self substringWithRange:beforeRange];
				[buf appendString:before];
			}
			// Now, figure out what was between those two strings
			{
				NSRange betweenRange = NSMakeRange(foundRange.location + startLength, foundRange.length - delimLength);
				NSString *between = [self substringWithRange:betweenRange];
				if (nil != inDict)
				{
					between = [inDict objectForKey:between];	// replace string
				}
				// Now append the between value if not nil
				if (nil != between)
				{
					[buf appendString:[between description]];
				}
			}
			// Now, update things and move on.
			range.length = NSMaxRange(range) - NSMaxRange(foundRange);
			range.location = NSMaxRange(foundRange);
		}
		else
		{
			NSString *after = [self substringWithRange:range];
			[buf appendString:after];
			// Now, update to be past the range, to finish up.
			range.location = NSMaxRange(range);
			range.length = 0;
		}
	}
	// Finally, append stuff after the search range
	{
		NSRange afterSearchRange = NSMakeRange(range.location, [self length] - range.location);
		[buf appendString:[self substringWithRange:afterSearchRange]];
	}
	return [NSString stringWithString:buf];
}

//===========================================================
/*"	Replace between the two given strings with the given options inMask; the delimeter strings are not included in the result.  The inMask parameter is the same as is passed to [NSString rangeOfString:options:range:].
"*/

- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2
						 fromDictionary:(NSDictionary *)inDict
							options:(unsigned)inMask

{
	return [self replaceAllTextBetweenString:inString1 andString:inString2
								fromDictionary:inDict 
							  	options:inMask
								range:NSMakeRange(0,[self length])];
}
//===========================================================
/*"	Replace between the two given strings with the default options; the delimeter strings are not included in the result.
"*/

- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2
										fromDictionary:(NSDictionary *)inDict
{
	return [self replaceAllTextBetweenString:inString1 andString:inString2 fromDictionary:inDict options:0];
}
//===========================================================
// Find a string from one string to another with the default options; the delimeter strings are included in the result.
- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2
{
	return [self rangeFromString:inString1 toString:inString2 options:0];
}

//===========================================================
// Find a string from one string to another with the given options inMask; the delimeter strings %are included in the result.  The inMask parameter is the same as is passed to [NSString rangeOfString:options:range:].


- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2
	options:(unsigned)inMask
{
	return [self rangeFromString:inString1 toString:inString2
		options:inMask
		range:NSMakeRange(0,[self length])];
}

//===========================================================
//Find a string from one string to another with the given options inMask and the given substring range inSearchRange; the delimeter strings %are included in the result.  The inMask parameter is the same as is passed to [NSString rangeOfString:options:range:].
- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2
	options:(unsigned)inMask range:(NSRange)inSearchRange
{
	NSRange result;
	NSRange stringStart = NSMakeRange(inSearchRange.location,0); // if no start string, start here
	NSUInteger foundLocation = inSearchRange.location;	// if no start string, start here
	NSRange stringEnd = NSMakeRange(NSMaxRange(inSearchRange),0); // if no end string, end here
	NSRange endSearchRange;
	if (nil != inString1)
	{
		// Find the range of the list start
		stringStart = [self rangeOfString:inString1 options:inMask range:inSearchRange];
		if (NSNotFound == stringStart.location)
		{
			return stringStart;	// not found
		}
		foundLocation = NSMaxRange(stringStart);
	}
	endSearchRange = NSMakeRange( foundLocation, NSMaxRange(inSearchRange) - foundLocation );
	if (nil != inString2)
	{
		stringEnd = [self rangeOfString:inString2 options:inMask range:endSearchRange];
		if (NSNotFound == stringEnd.location)
		{
			return stringEnd;	// not found
		}
	}
	result = NSMakeRange (stringStart.location, NSMaxRange(stringEnd) - stringStart.location );
	return result;
}

//===========================================================
- (BOOL)containsString:(NSString *)aString
{
    return [self containsString:aString ignoringCase:NO];
}
//===========================================================
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag
{
    NSStringCompareOptions mask = (flag ? NSCaseInsensitiveSearch : NSLiteralSearch);
    NSRange range = [self rangeOfString:aString options:mask];
    return (range.length > 0);
}
//===========================================================
- (BOOL) containsCharacterFromSet:(NSCharacterSet *)set
{
	return ([self rangeOfCharacterFromSet:set].location != NSNotFound);
}

//===========================================================
//	Split a string into lines separated by any of the various newline characters.  Equivalent to componentsSeparatedByString:@"\n" but it works with the different line separators: \r, \n, \r\n, 0x2028, 0x2029 

- (NSArray *) componentsSeparatedByLineSeparators
{
	NSMutableArray *result	= [NSMutableArray array];
	NSRange range = NSMakeRange(0,0);
	NSUInteger start, end;
	NSUInteger contentsEnd = 0;

	while (contentsEnd < [self length])
	{
		[self getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:range];
		[result addObject:[self substringWithRange:NSMakeRange(start,contentsEnd-start)]];
		range.location = end;
		range.length = 0;
	}
	return result;
}

//===========================================================
- (int) hexValue {
	int n = 0;
	sscanf([self UTF8String], "%x", &n);
	return n;
}

//===========================================================
- (BOOL) isLessThanVersionString:(NSString*)otherVersion
{
	if([self compareWithVersionString:otherVersion] == NSOrderedAscending)
	{
		return TRUE;
	}
	
	return FALSE;
}
//===========================================================
// private
- (NSComparisonResult) compareWithVersionString:(NSString*)rightVersion
{
	NSString* leftVersion = self;

	int i;
	
	// Break version into fields (separated by '.')
	NSMutableArray *leftFields  = [[NSMutableArray alloc] initWithArray:[leftVersion  componentsSeparatedByString:@"."]];
	NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[rightVersion componentsSeparatedByString:@"."]];
	
	// Implict ".0" in case version doesn't have the same number of '.'
	if ([leftFields count] < [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[leftFields addObject:@"0"];
		}
	} else if ([leftFields count] > [rightFields count]) {
		while ([leftFields count] != [rightFields count]) {
			[rightFields addObject:@"0"];
		}
	}
	
	// Do a numeric comparison on each field
	for(i = 0; i < [leftFields count]; i++) {
		NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];
		if (result != NSOrderedSame) {
			return result;
		}
	}

	return NSOrderedSame;
}


@end

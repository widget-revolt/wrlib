// 
// NSString+WRAdditions.h
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


@interface NSString (WRAdditions) 

/// Create a string from a file
+ (NSString*) stringFromFile:(NSString*)fileName withExtension:(NSString*)extension;

/// Test whether a string is empty or NULL
+ (BOOL)isEmptyString:(NSString *)string;

///-- Testing and manipulation
- (BOOL) isInteger;
- (BOOL) isLessThanVersionString:(NSString*)otherVersion;


/// gets the integer value of a hex string
- (int) hexValue;


//--URL Encoding
+ (NSString*) urlParamStrFromDict:(NSDictionary*)paramDict;
- (NSString*) urlEncode;
- (NSString*) urlDecode;

/// Strips quotes from a string
- (NSString*) stripQuotes;

/// breaks up string according to line separators (good for ini parsers)
- (NSArray *) componentsSeparatedByLineSeparators;

// Range Utilities
- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2;
- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2 options:(unsigned)inMask;
- (NSRange) rangeFromString:(NSString *)inString1 toString:(NSString *)inString2 options:(unsigned)inMask range:(NSRange)inSearchRange;


//General search-and-replace mechanism to convert text between the given delimeters.  
//Pass in a dictionary with the keys of "from" strings, and the values of what to convert them to.  
//If not found in the dictionary,  the text will just be removed.  
//If the dictionary passed in is nil, then the string between the delimeters will put in the place of the whole range; 
//	this could be used to just strip out the delimeters.
//
//Requires -[NSString rangeFromString:toString:options:range:].


- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2
														fromDictionary:(NSDictionary *)inDict
																options:(unsigned)inMask 
																range:(NSRange)inSearchRange;

/*"	Replace between the two given strings with the given options inMask; the delimeter strings are not included in the result.  The inMask parameter is the same as is passed to [NSString rangeOfString:options:range:].
"*/

- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2
																fromDictionary:(NSDictionary *)inDict
																options:(unsigned)inMask;
							
/*"	Replace between the two given strings with the default options; the delimeter strings are not included in the result.
"*/

- (NSString *) replaceAllTextBetweenString:(NSString *)inString1 andString:(NSString *)inString2 fromDictionary:(NSDictionary *)inDict;
					
- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag;
- (BOOL) containsCharacterFromSet:(NSCharacterSet *)set;




// to munge , call clear string with key...to reverse do the same with obfuscated text - only use with ascii strings
//- (NSString *)obfuscate:(NSString *)string withKey:(NSString *)key;

@end

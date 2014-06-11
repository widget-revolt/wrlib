//
//  TouchXML+Additions.m
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



#import "TouchXML+WRAdditions.h"
#import "NSString+WRAdditions.h"

@implementation CXMLElement(WRAdditions)

- (NSString*) getAttribute:(NSString*)attrName
{
	NSString* retStr = NULL;
	
	CXMLNode* attrNode = [self attributeForName:attrName];
	if(!attrNode)
		return NULL;
		
	retStr = [attrNode stringValue];
	return retStr;
}

- (int) getAttributeAsInt:(NSString*)attrName
{
	return([self getAttributeAsInt:attrName defaultVal:0]);
}

- (int) getAttributeAsInt:(NSString*)attrName defaultVal:(int)defaultVal
{
	NSString* strVal = [self getAttribute:attrName];
	if(!strVal || [NSString isEmptyString:strVal])
		return defaultVal;
		
	int retVal = [strVal intValue];
	return retVal;
}

- (float) getAttributeAsFloat:(NSString*)attrName defaultVal:(float)defaultVal
{
	NSString* strVal = [self getAttribute:attrName];
	if(!strVal || [NSString isEmptyString:strVal])
		return defaultVal;
		
	float retVal = [strVal floatValue];
	return retVal;
}
- (float) getAttributeAsFloat:(NSString*)attrName
{
	return([self getAttributeAsFloat:attrName defaultVal:0.0]);
}

@end

//
//  UIFont+WRAdditions.m
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



#import "UIFont+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation UIFont (WRAdditions)

//===========================================================
+ (UIFont*) fontWithFont:(UIFont*)font fontSize:(float)fontSize
{
	UIFont* newFont = [UIFont fontWithName:font.fontName size:fontSize];
	return newFont;
}
//===========================================================
+ (UIFont*) fontWithFont:(UIFont*)font scale:(float)scale
{
	float pointSize = font.pointSize;
	pointSize = scale * pointSize;
	
	return([UIFont fontWithFont:font fontSize:pointSize]);
}

//===========================================================
- (CGFloat) actualLineHeight
{
	CGFloat lineHeight = 0.0;
	
	lineHeight = self.ascender + self.descender + self.leading;
	
	
    return lineHeight;
}

@end

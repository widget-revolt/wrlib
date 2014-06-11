//
//  UIView+WRAdditions.h
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



#import <UIKit/UIKit.h>

@interface UIView (WRAdditions)

// removes all child subviews.  Useful for clearing a scrolling view
// for instance [UIImageView class] for a gallery view
- (void) removeAllSubviewsOfType:(Class)classType;


//--animations
-(void)startWiggling;

//--view decorations
- (void) addDropShadow:(float)offsetX offsetY:(float)offsetY radius:(float)radius opacity:(float)opacity;
- (void) addRoundedCorners:(float)cornerRadius;
- (void) addBorder:(UIColor*)color width:(float)width;

//--view geometry
- (void) scaleFrame:(float)scale;

//--- Positioning
typedef enum
{
	eViewPos_fromLeft = 0,
	eViewPos_fromLeftPercent,
	eViewPos_fromRight,
	eViewPos_fromRightPercent,
	eViewPos_horizCenter,
	
} EnumWRViewXAnchorType;

typedef enum
{
	eViewPos_fromBottom = 0,
	eViewPos_fromBottomPercent,
	eViewPos_fromTop,
	eViewPos_fromTopPercent,
	eViewPos_vertCenter
	
} EnumWRViewYAnchorType;

/// generic relative positioning
- (void) positionInView:(UIView*)otherView offset:(CGPoint)offset xAnchorType:(EnumWRViewXAnchorType)xAnchorType yAnchorType:(EnumWRViewYAnchorType)yAnchorType;

@end

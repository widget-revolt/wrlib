//
//  UIView+WRAdditions.m
//
//  Copyright (c) 2014 Widget Revolt LLC.  All rights reserved
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



#import "UIView+WRAdditions.h"
#import "WRMacros.h"
#import <QuartzCore/QuartzCore.h>

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation UIView (WRAdditions)

//===========================================================
// removes all child subviews.  Useful for clearing a scrolling view
- (void) removeAllSubviewsOfType:(Class)classType
{
	for (UIView* subview in self.subviews)
	{
		if([subview isKindOfClass:classType]) {
			[subview removeFromSuperview];
		}
	}
}


#pragma mark - Wiggle animations

#define kWiggleBounceY 2.0f
#define kWiggleBounceDuration 1.0
#define kWiggleBounceDurationVariance 0.25

#define kWiggleRotateAngle 0.02f
#define kWiggleRotateDuration 1.0
#define kWiggleRotateDurationVariance 0.25

-(void)startWiggling {
    [UIView animateWithDuration:0
                     animations:^{
                         [self.layer addAnimation:[self rotationAnimation] forKey:@"rotation"];
                         [self.layer addAnimation:[self bounceAnimation] forKey:@"bounce"];
                         self.transform = CGAffineTransformIdentity;
                     }];
}

-(CAAnimation*)rotationAnimation {
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.values = @[@(-kWiggleRotateAngle), @(kWiggleRotateAngle)];
	
    animation.autoreverses = YES;
    animation.duration = [self randomizeInterval:kWiggleRotateDuration
                                    withVariance:kWiggleRotateDurationVariance];
    animation.repeatCount = HUGE_VALF;
	
    return animation;
}

-(CAAnimation*)bounceAnimation {
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.values = @[@(kWiggleBounceY), @(0.0)];
	
    animation.autoreverses = YES;
    animation.duration = [self randomizeInterval:kWiggleBounceDuration
                                    withVariance:kWiggleBounceDurationVariance];
    animation.repeatCount = HUGE_VALF;
	
    return animation;
}

-(NSTimeInterval)randomizeInterval:(NSTimeInterval)interval withVariance:(double)variance {
    double random = (arc4random_uniform(1000) - 500.0) / 500.0;
    return interval + variance * random;
}

#pragma mark - view decorations

//===========================================================
- (void) addDropShadow:(float)offsetX offsetY:(float)offsetY radius:(float)radius opacity:(float)opacity
{
	self.layer.shadowColor = RGBA_CG(0,0,0,1.0);
	self.layer.shadowOffset = CGSizeMake(offsetX, offsetY);
	self.layer.shadowRadius = radius;
	self.layer.shadowOpacity = opacity;
	
	// optimize the shadow drawing (since we're rectangular)
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}
//===========================================================
- (void) addRoundedCorners:(float)cornerRadius
{
	self.layer.masksToBounds = TRUE;
	self.layer.cornerRadius = cornerRadius;
}
//===========================================================
- (void) addBorder:(UIColor*)color width:(float)width
{
	self.layer.borderWidth = width;
	self.layer.borderColor = color.CGColor;
}

#pragma mark - view geometry

//===========================================================
- (void) scaleFrame:(float)scale
{
	CGRect currentFrame = self.frame;
	CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y,
								 currentFrame.size.width * scale,
								 currentFrame.size.height * scale);
	self.frame = newFrame;
}

//===========================================================
- (void) positionInView:(UIView*)otherView offset:(CGPoint)offset xAnchorType:(EnumWRViewXAnchorType)xAnchorType yAnchorType:(EnumWRViewYAnchorType)yAnchorType
{
	float svWidth = otherView.frame.size.width;
	float myWidth = self.frame.size.width;
	float svHeight = otherView.frame.size.height;
	float myHeight = self.frame.size.height;
	
	float xOffset, yOffset;
	float percentSize;
	
	switch(xAnchorType)
	{
		case eViewPos_fromLeft:
			xOffset = offset.x;
			break;
			
		case eViewPos_fromLeftPercent:
			percentSize = svWidth * offset.x;
			xOffset = percentSize;
			break;
			
		case eViewPos_fromRight:
			xOffset = svWidth - offset.x - myWidth;	// pos from right but anchored on left
			break;
			
		case eViewPos_fromRightPercent:
			percentSize = svWidth * offset.x;
			xOffset = svWidth - percentSize - myWidth;	// pos from right but anchored on left
			break;
			
		case eViewPos_horizCenter:
			xOffset = (svWidth - myWidth) * 0.5;
			break;
	}
	
	switch(yAnchorType)
	{
		case eViewPos_fromBottom:
			yOffset = svHeight - offset.y - myHeight;
			break;
			
		case eViewPos_fromBottomPercent:
			percentSize = svHeight * offset.y;
			yOffset = svHeight - percentSize - myHeight;
			break;
			
		case eViewPos_fromTop:
			yOffset = offset.y;
			break;
			
		case eViewPos_fromTopPercent:
			percentSize = svHeight * offset.y;
			yOffset = percentSize;
			break;
			
		case eViewPos_vertCenter:
			yOffset = (svHeight - myHeight) * 0.5 ;
			break;
	}
	
	[self setPosition:CGPointMake(xOffset, yOffset)];
	
}

//===========================================================
- (void) setPosition:(CGPoint)pos
{
	[self setX:pos.x andY:pos.y];
}
//===========================================================
- (id)setX:(CGFloat)x andY:(CGFloat)y
{
    CGRect f = self.frame;
    self.frame = CGRectMake(x, y,
                            f.size.width, f.size.height);
    return self;
}

@end

//
//  UIButton+WRAdditions.m
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


#import "UIButton+WRAdditions.h"
#import <SpriteKit/SpriteKit.h>
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation UIButton (WRAdditions)

//===========================================================
+ (UIButton*) buttonWithImage:(NSString*)imageName
{
	UIImage* buttonImage = [UIImage imageNamed:imageName];
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.frame = CGRectMake(0,0,buttonImage.size.width, buttonImage.size.height);
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	
	return button;
}
//===========================================================
+ (UIButton*) buttonWithImage:(NSString*)imageName andText:(NSString*)text inRect:(CGRect)rect
{
	UIImage* buttonImage = [UIImage imageNamed:imageName];
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.frame = CGRectMake(0,0,rect.size.width, buttonImage.size.height);
	
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button setTitle:text forState:UIControlStateNormal];

	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	return button;
}

#pragma mark - UIButton blocks support

static char UIButtonWRBlockOverviewKey;

@dynamic wrBlockActions;

//===========================================================
- (void) setDefaultActionBlock:(void(^)())block
{
	[self setAction:kUIButtonBlockTouchUpInside withBlock:block];
}

//===========================================================
- (void) setAction:(NSString*)action withBlock:(void(^)())block {
    
    if ([self wrBlockActions] == nil) {
        [self setWrBlockActions:[[NSMutableDictionary alloc] init]];
    }
    
    [[self wrBlockActions] setObject:block forKey:action];
    
    if ([kUIButtonBlockTouchUpInside isEqualToString:action]) {
        [self addTarget:self action:@selector(doTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
}
//===========================================================
- (void)setWrBlockActions:(NSMutableDictionary*)actions {
    objc_setAssociatedObject (self, &UIButtonWRBlockOverviewKey,actions,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//===========================================================
- (NSMutableDictionary*)wrBlockActions {
    return objc_getAssociatedObject(self, &UIButtonWRBlockOverviewKey);
}
//===========================================================
- (void)doTouchUpInside:(id)sender {
    void(^block)();
    block = [[self wrBlockActions] objectForKey:kUIButtonBlockTouchUpInside];
    block();
}
@end

//
//  UIAlertView+WRAdditions.m
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



#import "UIAlertView+WRAdditions.h"
#import <objc/runtime.h>


#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

static char DISMISS_IDENTIFER;



@implementation UIAlertView (WRAdditions)

@dynamic dismissBlock;

//===========================================================
- (void)setDismissBlock:(WRAlertViewDismissBlock)dismissBlock
{
    objc_setAssociatedObject(self, &DISMISS_IDENTIFER, dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//===========================================================
- (WRAlertViewDismissBlock)dismissBlock
{
    return objc_getAssociatedObject(self, &DISMISS_IDENTIFER);
}

//===========================================================
+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message
				  cancelButtonTitle:(NSString*) cancelButtonTitle
				  otherButtonTitles:(NSArray*) otherButtons
						  onDismiss:(WRAlertViewDismissBlock) dismissed
{
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    [alert setDismissBlock:dismissed];
    
    for(NSString* buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
	}
    

    return alert;//[alert autorelease];  ARC fix
}
//===========================================================
+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message {
    
    return [UIAlertView alertViewWithTitle:title
                                   message:message
                         cancelButtonTitle:NSLocalizedString(@"OK", @"")];
}
//===========================================================
+ (UIAlertView*) alertViewWithTitle:(NSString*) title
							message:(NSString*) message
				  cancelButtonTitle:(NSString*) cancelButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];

    return alert;//[alert autorelease];  ARC fix
}

//===========================================================
+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
	if (alertView.dismissBlock) {
		alertView.dismissBlock((int)buttonIndex); // cancel button is button 0
	}
}

@end

//
//  UITableViewCell+WRAdditions.m
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



#import "UITableViewCell+WRAdditions.h"
#import <QuartzCore/QuartzCore.h>

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation UITableViewCell (WRAdditions)

- (void)addShadowToCellInTableView:(UITableView *)tableView
                       atIndexPath:(NSIndexPath *)indexPath
{
	BOOL isFirstRow = !indexPath.row;
	BOOL isLastRow = (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1);
	
	// the shadow rect determines the area in which the shadow gets drawn
	CGRect shadowRect = CGRectInset(self.backgroundView.bounds, 0, -10);
	if(isFirstRow)
		shadowRect.origin.y += 10;
	else if(isLastRow)
		shadowRect.size.height -= 10;
	
	// the mask rect ensures that the shadow doesn't bleed into other table cells
	CGRect maskRect = CGRectInset(self.backgroundView.bounds, -20, 0);
	if(isFirstRow) {
		maskRect.origin.y -= 10;
		maskRect.size.height += 10;
	}
	else if(isLastRow)
		maskRect.size.height += 10;
	
	// now configure the background view layer with the shadow
	CALayer *layer = self.backgroundView.layer;
	layer.shadowColor = [UIColor redColor].CGColor;
	layer.shadowOffset = CGSizeMake(0, 0);
	layer.shadowRadius = 3;
	layer.shadowOpacity = 0.75;
	layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:5].CGPath;
	layer.masksToBounds = NO;
	
	// and finally add the shadow mask
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRect:maskRect].CGPath;
	layer.mask = maskLayer;
}

@end

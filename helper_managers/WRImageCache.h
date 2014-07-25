//
//  WRImageCache.h
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

//This is a braindead simple cache implementation with ZERO cleanup strategy.  It is relying on the good graces of the NSTemporaryDirectory and the iOS system to cleanup these temp files as it see fit.  This is not a workable strategy on android.
// This class relies on AFNetworking.   If you do not define anything it will use AFNetworking 2.x
// If you otherwise define WRB_USE_AFNETWORKING20 as 0 then it will use AFNetworking 1.x

@interface WRImageCache : NSObject

+ (WRImageCache*) sharedManager;

- (void) setDefaultImage:(UIImage*)image;
- (UIImage*) getImageForUrl:(NSURL*)url;
- (NSString*) pathToImageForUrl:(NSURL*)url;

@end

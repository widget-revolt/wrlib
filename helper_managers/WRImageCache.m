//
//  WRImageCache.m
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

#import "WRImageCache.h"
#import "AFHTTPRequestOperationManager.h"

//http://www.widgetrevolt.com/site_media/images/theme-pics/services.png


static WRImageCache* gSharedInstance_ImageCache = NULL;

/////////////////////////////////////////////////////////////////////
@interface WRImageCache()

@property (nonatomic, strong) UIImage* mDefaultImage;	// this lets you

@end

/////////////////////////////////////////////////////////////////////
@implementation WRImageCache

//==============================================================
+ (WRImageCache*) sharedManager
{
	static dispatch_once_t onceQueue;
	
    dispatch_once(&onceQueue, ^{
        gSharedInstance_ImageCache = [[WRImageCache alloc] init];
    });
	
    return gSharedInstance_ImageCache;
}
//===========================================================
- (void) setDefaultImage:(UIImage*)image
{
	self.mDefaultImage = image;
}
//===========================================================
- (NSString*) sanitizeFileNameString:(NSString*)fileName
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?&!@:%*|\"<>"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

//===========================================================
- (NSString*) sanitizeURL:(NSURL*)url
{
	NSString* urlString = [url absoluteString];
	NSString* fileName = [self sanitizeFileNameString:urlString];
	
	return fileName;
}

//===========================================================
//ANDROID - needs to change
- (BOOL) cacheImage:(UIImage*)image forURL:(NSURL*)url
{
	NSString* fileName = [self sanitizeURL:url];
	
	// these will all be saved as PNGs
	fileName = [fileName stringByAppendingString:@".png"];
	
	WRDebugLog(@"Caching image: %@", fileName);
	BOOL ok = [WRUtils saveImageToTempDir:image withName:fileName];
	
	return ok;

}

//===========================================================
- (UIImage*) getImageForUrl:(NSURL*)url
{
	NSString* fileName = [self sanitizeURL:url];
	fileName = [fileName stringByAppendingString:@".png"];
	
	NSURL* fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
	UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:fileURL]];
	
	if(!image)
	{
		if(_mDefaultImage) {
			image = [_mDefaultImage copy];
		}
		
		// start a load from the url now to fetch the image
		
		AFHTTPRequestOperationManager* httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
		httpClient.responseSerializer = [AFImageResponseSerializer serializer];
		
		NSString* resource = [url resourceSpecifier];
		[httpClient GET:resource parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
			UIImage* responseImage = (UIImage*) responseObject;
			if(responseImage) {
				[self cacheImage:responseImage forURL:url];
			}
		
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			WRErrorLog(@"Error fetching image for URL: %@, error: %@", url, error);
		}];
	}
	
	return image;
}

//===========================================================
- (NSString*) pathToImageForUrl:(NSURL*)url
{
	return @"";
}

@end

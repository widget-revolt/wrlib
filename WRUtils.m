//
//  WRUtils.m
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

#include <CommonCrypto/CommonDigest.h>
#import "WRUtils.h"
#import "WRLogging.h"

#import "NSString+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation WRUtils

//===========================================================
+ (NSString*) localizedString:(NSString*)s withSubstitutions:(NSArray*)subArray
{
	NSString* theString = NSLocalizedString(s, @"");
	
	NSUInteger len = [subArray count];
	if(len % 2 != 0)
	{
		WRErrorLog(@"called localizedStringWithSubstituions with invalid subArray!");
		return theString;
	}
	
	for(int i = 0; i < len; i += 2)
	{
		
		NSString* srcStr = subArray[0];
		NSString* dstStr = subArray[1];
		
		theString = [theString stringByReplacingOccurrencesOfString:srcStr withString:dstStr];
	}
	
	return theString;
}

//===========================================================
+(CGSize) currentScreenSize
{
	return [WRUtils screenSizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

//===========================================================
+(CGSize) screenSizeInOrientation:(UIInterfaceOrientation)orientation
{
	CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

//===========================================================
// Creates a UUID (aka GUID) 

+ (NSString *) createUUIDString
{
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  
  NSString* retStr = (__bridge NSString *)string;
  return retStr;
}
//===========================================================
+ (NSString*) getAppName
{
	return([[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]);
}

//===========================================================
// returns version info in the form <short version> (bundleversion) 
// ex: v1.0 (203)
+ (NSString*) getAppVersionInfo
{

	NSString* shortVersionStr =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString* buildVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	return([NSString stringWithFormat:@"v%@ (%@)", shortVersionStr, buildVersionStr]);
}

//===========================================================
// returns version info in the form nn.nn.nn.nn
+ (NSString*) getAppVersionInfoStd
{
	
	NSString* shortVersionStr =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString* buildVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// pull apart short version string and add 0s if not enough decimals
	NSArray* versArray = [shortVersionStr componentsSeparatedByString:@"."];
	int clen = (int) [versArray count];
	int addCount = 3 - clen;
	if(addCount > 0)
	{
		for(int i = 0; i < addCount; i++)
		{
			shortVersionStr = [shortVersionStr stringByAppendingString:@".0"];
		}
	}
	
	return([NSString stringWithFormat:@"%@.%@", shortVersionStr, buildVersionStr]);
}

//===========================================================
+ (NSString*) getBundleIdentifier
{
	return([[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleIdentifier"]);
}
//===========================================================
+ (NSString*) getOSSystemName
{
	NSString* systemName = [UIDevice currentDevice].systemName;
	NSString* version = [UIDevice currentDevice].systemVersion;
	
	NSString* baseStr = [NSString stringWithFormat:@"%@ %@", systemName, version];
	
	return baseStr;
}

//===========================================================
+ (BOOL)isIPad
{
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            return YES;
        }
    }
    return NO;
}
//===========================================================
+ (BOOL)isIPhone
{
    return(![WRUtils isIPad]);
}
//===========================================================
// CHANGED from older version.   Preserve the extension
+ (NSString *)addIPadSuffixWhenOnIPad:(NSString *)resourceName
{
    if([WRUtils isIPad])
	{
		NSString* extension = [resourceName pathExtension];
		NSString* baseName = [resourceName stringByDeletingPathExtension];
		
		if([extension length] > 0)
		{
			extension = [NSString stringWithFormat:@".%@", extension];
		}
		
		NSString* retStr = [NSString stringWithFormat:@"%@-ipad%@", baseName, extension];
		
        return retStr;
		
    }
    else {
        return resourceName;
    }   
}

//=======================================================================================
+ (NSString *)addHDSuffixWhenOnIPad:(NSString *)resourceName
{
    if([WRUtils isIPad]){
		
		NSString* extension = [resourceName pathExtension];
		NSString* baseName = [resourceName stringByDeletingPathExtension];
		
		NSString* retStr = [NSString stringWithFormat:@"%@-hd.%@", baseName, extension];
		
        return retStr;
    }
    else {
        return resourceName;
    }
}


//===========================================================
// creates a dict of key value pairs from a url parameter string
+ (NSDictionary*) urlParamStrToDict:(NSString*)parameterString
{
	NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] init];
	
	@try
	{
		// separate by & symbol
		NSArray* components = [parameterString componentsSeparatedByString:@"&"];
		for(NSString* kvPair in components)
		{
			NSArray* kvComponents = [kvPair componentsSeparatedByString:@"="];
			if([kvComponents count] == 2)
			{
				NSString* baseValue = [kvComponents objectAtIndex:1];
				NSString* realValue = [baseValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				[mutableDict setObject:realValue forKey:[kvComponents objectAtIndex:0]];
			}
		}
	}
	@catch(id exerr)
	{
		WRDebugLog(@"Exception in WRUtils::urlParamStrToDict");
	}
	
	
	NSDictionary* retDict = [NSDictionary dictionaryWithDictionary:mutableDict];
	return retDict;
}
//===========================================================
+ (void) openExternalURL:(NSString*)urlStr
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
//===========================================================
+ (void) callNumber:(NSString*)number
{
	NSMutableString *phone = [number mutableCopy];
	[phone replaceOccurrencesOfString:@" " 
						   withString:@"" 
							  options:NSLiteralSearch 
								range:NSMakeRange(0, [phone length])];
	[phone replaceOccurrencesOfString:@"(" 
						   withString:@"" 
							  options:NSLiteralSearch 
								range:NSMakeRange(0, [phone length])];
	[phone replaceOccurrencesOfString:@")" 
						   withString:@"" 
							  options:NSLiteralSearch 
								range:NSMakeRange(0, [phone length])];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark - directory helpers
//===========================================================
// returns path to documents directory

+ (NSString *)getDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//===========================================================
// given a filename, returns the path to that file in the documents directory

+ (NSString*) filePathInDocumentsDirectory:(NSString*)fileName
{
	NSString* docsDir = [WRUtils getDocumentsDirectory];
	
	NSString* retStr = [docsDir stringByAppendingPathComponent:fileName];
	
	return retStr;
}
//===========================================================
+ (BOOL) deleteFileInDocumentsIfExists:(NSString*)fileName
{
	BOOL wasDeleted = FALSE;
	
	NSString* fullPath = [WRUtils filePathInDocumentsDirectory:fileName];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSError* error;
	wasDeleted = [fileManager removeItemAtPath:fullPath error:&error];
	
	return wasDeleted;
}
//===========================================================
+ (BOOL) renameFileInDocuments:(NSString*)srcFileName toName:(NSString*)dstFileName overwrite:(BOOL)overwrite
{

	if([NSString isEmptyString:srcFileName]) {
		return FALSE;
	}
	if([NSString isEmptyString:dstFileName]) {
		return FALSE;
	}

	NSString* srcPath = [WRUtils filePathInDocumentsDirectory:srcFileName];
	NSString* dstPath = [WRUtils filePathInDocumentsDirectory:dstFileName];
	
	NSFileManager* fileMgr = [NSFileManager defaultManager];
	NSError* error;
	BOOL ok = [fileMgr copyItemAtPath:srcPath toPath:dstPath error:&error];
	
	if(!ok)
	{
		WRErrorLog(@"error on rename: %@", error);
	
		// if overwrite
		if(!overwrite) {
			return FALSE;
		}
		
		// try delete
		[WRUtils deleteFileInDocumentsIfExists:dstFileName];
		ok = [fileMgr copyItemAtPath:srcPath toPath:dstPath error:&error];
		WRErrorLog(@"retrying...error on rename: %@", error);
	}
	
	if(ok)
	{
		// delete source
		[WRUtils deleteFileInDocumentsIfExists:srcFileName];
	}
	
	return ok;
}
//===========================================================
+ (BOOL) saveImageToDocuments:(UIImage*)image imageData:(NSData*)imageData withName:(NSString*)imageFileName
{
	return([WRUtils saveImageToDocuments:image imageData:imageData withName:imageFileName useJPEG:FALSE]);
}

//===========================================================
// saves a UIImage with name to the documents directory.  Return YES if saved
// if image and imageData are mutually exclusive.  Use image and imageData=nil in most cases
+ (BOOL) saveImageToDocuments:(UIImage*)image imageData:(NSData*)imageData withName:(NSString*)imageFileName  useJPEG:(BOOL)useJpeg
{
	
	NSData* theImageData = NULL;
	
	if(image)
	{
		if(useJpeg) {
			theImageData = UIImageJPEGRepresentation(image, 1.0);
		}
		else {
			theImageData = UIImagePNGRepresentation(image);
		}
	}
	else
	{
		theImageData = imageData;
	}
	assert(theImageData != NULL);
	
	
	NSString* fullPath = [WRUtils filePathInDocumentsDirectory:imageFileName];
	
	BOOL fileWasSaved = [theImageData writeToFile:fullPath atomically:NO];
	
	return fileWasSaved;
	
}

//===========================================================
/// Saves image to temp dir
+ (BOOL) saveImageToTempDir:(UIImage*)image withName:(NSString*)imageFileName
{
	NSData* theImageData = UIImagePNGRepresentation(image);
	
	NSURL* fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:imageFileName]];
	
	NSError* error;
	BOOL ok = [theImageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
	return ok;
}

//===========================================================
// returns path to library directory


+ (NSString *)getApplicationLibraryDirectory 
{  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);  
    return [paths objectAtIndex:0];  
}  

#pragma mark - hash

//===========================================================
// old version for reference
+ (NSString*) oldmd5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, (CC_LONG) strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
//===========================================================
+ (NSString*) md5:(NSString*)str
{
	NSString* nsInputStr = str;
	
	const char* cStr = [nsInputStr UTF8String];
	unsigned char digest[16];
	CC_MD5( cStr, (CC_LONG) strlen(cStr), digest ); // This is the md5 call
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}
//===========================================================
+ (NSString*) sha1:(NSString*)str
{
	NSString* dataStr = str;
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
	
	//	const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
	//	NSData *data = [NSData dataWithBytes:cstr length:input.length];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, (CC_LONG) data.length, digest);
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}
//===========================================================
+ (NSString*) sha256:(NSString*)str
{
	// convert input to nsdata
    NSString* dataStr = str;
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

    // hash it
    unsigned char valueBuf[CC_SHA256_DIGEST_LENGTH];
    CC_LONG len = (CC_LONG) [data length];
    CC_SHA256([data bytes], len, valueBuf);
    
    // convert to "hexified" output and then back to string
    NSMutableString* stringValue = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
	NSInteger i;
	for (i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		[stringValue appendFormat:@"%02x", valueBuf[i]];
	}
    
	return stringValue;
}

//===========================================================
+ (NSString*) sha256AsBase64Digest:(NSString*)str
{
	// convert input to nsdata
    NSString* dataStr = str;
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
	
    // hash it
    unsigned char valueBuf[CC_SHA256_DIGEST_LENGTH];
    CC_LONG len = (CC_LONG)[data length];
    CC_SHA256([data bytes], len, valueBuf);
	
	NSData* outData = [NSData dataWithBytes:valueBuf length:CC_SHA256_DIGEST_LENGTH];
	NSString* base64 =[outData base64EncodedString:FALSE];
	
	return base64;
}

@end

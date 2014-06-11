//
//  WRUtils.h
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

#define LOCALSTRSUB(s, subArray)		[WRUtils localizedString:s withSubstitutions:subArray]

@interface WRUtils : NSObject {

}


+ (NSString*) localizedString:(NSString*)s withSubstitutions:(NSArray*)subArray;

// -- screen utils
+(CGSize) currentScreenSize;
+(CGSize) screenSizeInOrientation:(UIInterfaceOrientation)orientation;

// -- /Document folder
+ (NSString*) getDocumentsDirectory;
+ (NSString*) filePathInDocumentsDirectory:(NSString*)fileName;
+ (BOOL) deleteFileInDocumentsIfExists:(NSString*)fileName;
+ (BOOL) renameFileInDocuments:(NSString*)srcFileName toName:(NSString*)dstFileName overwrite:(BOOL)overwrite;

	/// saves a UIImage with name to the documents directory.  Return YES if saved
	/// if image and imageData are mutually exclusive.  Use image and imageData=nil in most cases
+ (BOOL) saveImageToDocuments:(UIImage*)image imageData:(NSData*)imageData withName:(NSString*)imageFileName;
+ (BOOL) saveImageToDocuments:(UIImage*)image imageData:(NSData*)imageData withName:(NSString*)imageFileName useJPEG:(BOOL)useJpeg;

/// Saves image to temp dir
+ (BOOL) saveImageToTempDir:(UIImage*)image withName:(NSString*)imageFileName;

+ (NSString *)getApplicationLibraryDirectory;


// -- general/misc. utils
+ (NSString*) createUUIDString;		// create a UUID/GUID 
+ (NSString*) getAppName;
+ (NSString*) getAppVersionInfo;
+ (NSString*) getAppVersionInfoStd;	// returns in form 1.0.0.x
+ (NSString*) getBundleIdentifier;
+ (NSString*) getOSSystemName;


+ (NSDictionary*) urlParamStrToDict:(NSString*)parameterString;
+ (void) openExternalURL:(NSString*)urlStr;

+ (void) callNumber:(NSString*)number;

+ (BOOL)isIPad;
+ (BOOL)isIPhone;
+ (NSString *)addIPadSuffixWhenOnIPad:(NSString *)resourceName; // adds an -ipad suffix to a resource on ipad (e.g.  foo-ipad.png)
+ (NSString *)addHDSuffixWhenOnIPad:(NSString *)resourceName;	// adds an -hd suffix to a resource on ipad (e.g.  foo-hd.png)


// -- hash
+ (NSString*) md5:(NSString *)str;
+ (NSString*) sha1:(NSString*)str;
+ (NSString*) sha256:(NSString*)str;
+ (NSString*) sha256AsBase64Digest:(NSString*)str;



@end

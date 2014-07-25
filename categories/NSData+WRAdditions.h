//
//  NSData+WRAdditions.h
//
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

@interface NSData (WRAdditions)

//-- base64
+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString:(BOOL)withNewLines;

//--hex
- (NSString*) stringWithHexBytes;

//--simple encryption
// This was taken from stackoverflow here:
// http://stackoverflow.com/questions/8287727/aes256-nsstring-encryption-in-ios?rq=1
// I would suggest only using it for basic obfuscation

// Be warned that this is pretty insecure.  If you need security, suggest using RNCrypt:
// http://robnapier.net/aes-commoncrypto/

- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;

#define USE_ZLIB 1

#if USE_ZLIB
//-- zlib
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

//-- gzip
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
#endif

@end

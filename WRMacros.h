// 
// WRMacros.h
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


#pragma once

#define RANDOM_SEED() srandom((unsigned int) time(NULL));

// this returns a number between __MIN__ and __MAX__ *inclusive.
// ex if min = 0 and max = 4 then numbers returned are 0,1,2,3,4
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define RANDOM_FLOAT(__MIN__, __MAX__) ((float) RANDOM_INT(__MIN__, __MAX__))
#define RANDOM_PERCENT() (RANDOM_FLOAT(0,100)/100.0f)

#define TICKCOUNT()		[[NSProcessInfo processInfo] systemUptime]

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGBA_CG(r, g, b, a) [[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a] CGColor]

// Localization
#define LOCALSTR(x)		NSLocalizedString(x, @"")

// NSError
#define MAKE_NSERROR(d, c, s)  [NSError errorWithDomain:d code:c userInfo:@{ NSLocalizedDescriptionKey: s } ];

//System Versioning Preprocessor Macros


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



/*
 Ex:
 if(Bitfield_Is_Set(field, theFlag)
 ...
 
 // toggle a flag
 field = Bitfield_Toggle(field, flag);
 
 // mask out a flag
 field = Bitfield_Mask(field, maskFlag);
 */
#define Bitfield_Is_Set(field, flag)	((field & flag) != 0 )
#define Bitfield_Toggle(field, flag)	(field ^ flag)
#define Bitfield_Mask(field, mask)		(field & ~mask)
#define Bitfield_Set(field, flag)		(field | flag)
#define Bitfield_Unset(field, flag)		(field & ~flag)

//--Sprite Kit
//#define SK_RGBA(r,g,b,a) [SKColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
//#define ccp(x,y)	CGPointMake(x,y)

//System Versioning Preprocessor Macros



// Widescreen detection
#define IS_WIDESCREEN() ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA() ([[UIScreen mainScreen] scale] == 2.0f)
#define IS_IPADHD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] scale] == 2.0f)


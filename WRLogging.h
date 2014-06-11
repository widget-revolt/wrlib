//
//  WRLogging.h
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


#ifndef __WRLOGGING_H__
#define __WRLOGGING_H__


// Set this switch to 1 to include code location
#ifndef LOGGING_INCLUDE_CODE_LOCATION
#define LOGGING_INCLUDE_CODE_LOCATION	0
#endif

//////////////////////////////////////////////////////////////////////////////////
/// COLOR SUPPORT via xcode colors
// How to apply color formatting to your log statements:
//
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
//
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
//
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
//
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
//
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"

#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["


#if TARGET_OS_IPHONE
	#if TARGET_IPHONE_SIMULATOR
		#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
	#else
		#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
	#endif

#else
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define XCODE_COLORS_RED	@"fg255,0,0;"

//////////////////////////////////////////////////////////////////////////////////
// Logging format
#define WRLOG_FORMAT_NO_LOCATION(esc, color, fmt, lvl, ...) NSLog((@"%@%@[%@] " fmt), esc, color, lvl, ##__VA_ARGS__)
#define WRLOG_FORMAT_WITH_LOCATION(esc, color, fmt, lvl, ...) NSLog((@"%@%@%s[Line %d] [%@] " fmt), esc, color,  __PRETTY_FUNCTION__, __LINE__, lvl, ##__VA_ARGS__)

#if defined(LOGGING_INCLUDE_CODE_LOCATION) && LOGGING_INCLUDE_CODE_LOCATION
#define WRLOG_FORMAT(esc, color, fmt, lvl, ...) WRLOG_FORMAT_WITH_LOCATION(esc, color, fmt, lvl, ##__VA_ARGS__)
#else
#define WRLOG_FORMAT(esc, color, fmt, lvl, ...) WRLOG_FORMAT_NO_LOCATION(esc, color, fmt, lvl, ##__VA_ARGS__)
#endif

#define kLogTypeStr_trace	@"trace"
#define kLogTypeStr_debug	@"debug"
#define kLogTypeStr_info	@"info "
#define kLogTypeStr_err		@"error"

#define kLogColor_trace		@"fg64,64,64;"
#define kLogColor_debug		@"fg0,0,0;"
#define kLogColor_info		@"fg0,0,255;"
#define kLogColor_error		@"fg255,0,0;"


// set this to 1 to kill all colors
#if 1
#undef XCODE_COLORS_ESCAPE
#undef kLogColor_trace
#undef kLogColor_debug
#undef kLogColor_info
#undef kLogColor_error

#define XCODE_COLORS_ESCAPE @""
#define kLogColor_trace		@""
#define kLogColor_debug		@""
#define kLogColor_info		@""
#define kLogColor_error		@""

#endif


// only info and error are available in non debug - all in debug versions
// error and trace logs always print file/line

#ifdef DEBUG

#define WRTraceLog(fmt, ...) WRLOG_FORMAT_WITH_LOCATION(XCODE_COLORS_ESCAPE, kLogColor_trace,fmt, kLogTypeStr_trace, ##__VA_ARGS__)
#define WRDebugLog(fmt, ...) WRLOG_FORMAT(XCODE_COLORS_ESCAPE, kLogColor_debug, fmt, kLogTypeStr_debug, ##__VA_ARGS__)

#else

#define WRTraceLog(...) do {} while (0)
#define WRDebugLog(...) do {} while (0)

#endif

#define WRInfoLog(fmt, ...) WRLOG_FORMAT(XCODE_COLORS_ESCAPE, kLogColor_info, fmt, kLogTypeStr_info, ##__VA_ARGS__)
#define WRErrorLog(fmt, ...) WRLOG_FORMAT_WITH_LOCATION(XCODE_COLORS_ESCAPE, kLogColor_error,fmt, kLogTypeStr_err, ##__VA_ARGS__)




#endif



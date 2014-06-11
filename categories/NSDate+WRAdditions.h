//
//  NSDate+WRAdditions.h
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


#define kNSDate_MFAdditions_SecondsPerDay		( (float)(60.0*60.0*24.0))

@interface NSDate (WRAdditions)

+ (NSString*) timeIntervalToTimeStr:(NSTimeInterval)timeInterval;//HH:mm:ss
+ (NSString*) timeIntervalToShortTimeStr:(NSTimeInterval)timeInterval;	//mm:ss

+ (NSDate*) dateWithHours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds;
+ (NSDate*) dateForShortDateString:(NSString*)timeStr;

	// these would be better in a date additions category
- (NSDate*) setDateForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (NSDate*) zeroBaseDateForTime;
- (NSDate*) zeroSecondsComponent;
- (NSDate*) setTimeToToday;
- (NSDate*) setTimeOnSameDate:(NSDate*)sameDate;
- (NSDate*) timeOnNextDay;
- (NSDate*) timeByAddingDays:(NSInteger)days;
- (NSInteger) dayOfWeek;
- (NSString*) relativeTimeStr;


	// a special method for the alarm clock.  This takes a start date (receiver) and enddate and subdivides it and returns an array of times in order

+ (NSDate*) nextTimeFromArray:(NSArray*)dateArray;
- (NSArray*) datesTimeSubdividedEndingAt:endRepeatTime subdivided:(NSInteger)numTimes;

@end

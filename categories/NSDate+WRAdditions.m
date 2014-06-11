//
//  NSDate+WRAdditions.m
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



#import "NSDate+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSDate (WRAdditions)

//===========================================================
+ (NSString*) timeIntervalToTimeStr:(NSTimeInterval)timeInterval
{
	NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];

	NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
	[timeFormat setDateFormat:@"HH:mm:ss"];
	
	NSString* dateStr = [timeFormat stringFromDate:date];
	
	return dateStr;
}

//===========================================================
+ (NSString*) timeIntervalToShortTimeStr:(NSTimeInterval)timeInterval
{
	NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
	
	NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
	[timeFormat setDateFormat:@"mm:ss"];
	
	NSString* dateStr = [timeFormat stringFromDate:date];
	
	return dateStr;
}


//===========================================================
- (NSDate*) setDateForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
	// create a temp calendar
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	const unsigned units    = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* components = [gregorian components:units fromDate:self];
    
	[components setDay:day];
	[components setMonth:month];
	[components setYear:year];

	NSDate* date = [gregorian dateFromComponents:components];
	
	return date;
}
//===========================================================
+ (NSDate*) dateWithHours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds
{
	// create a temp calendar
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	const unsigned units    = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDate* now = [NSDate date];
    NSDateComponents* components = [gregorian components:units fromDate:now];
    
	[components setHour:hours];
	[components setMinute:minutes];
	[components setSecond:seconds];
	
	NSDate* date = [gregorian dateFromComponents:components];
	
	return date;
}

//===========================================================
+ (NSDate*) dateForShortDateString:(NSString*)timeStr
{
	NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];

	NSDate* date = [dateFormat dateFromString:timeStr];
	return date;
}

//===========================================================
/*!
    @method     - (NSDate*) zeroSecondsComponent
    @abstract   Clears the second component from a date which is set to the current seconds from a date picker control!
    @discussion see above
*/
- (NSDate*) zeroSecondsComponent
{
	// create a temp calendar
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	const unsigned units    = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* components = [gregorian components:units fromDate:self];
    
	[components setSecond:0];

	NSDate* date = [gregorian dateFromComponents:components];
	
	return date;
}	

//===========================================================
/*!
    @method     - (NSDate*) zeroBaseDateForTime:(NSDate*)theDate
    @abstract   Takes date and zero-bases (sets it to jan 1, 1970)
    @discussion Use this method to do time calculations based on an NSDate
*/
- (NSDate*) zeroBaseDateForTime
{

	NSDate* date = [self setDateForYear:1970 month:1 day:1];
	
	return date;

}	

//===========================================================
/*!
    @method     - (NSDate*) setTimeToToday
    @abstract   sets the date component of a date to today and leaves the time component alone
    @discussion Use this method to do time calculations based on an NSDate
*/
- (NSDate*) setTimeToToday
{
	NSDate* now = [NSDate date];
	
	NSDate* retDate = [self setTimeOnSameDate:now];

	
	return retDate;
	
}
//===========================================================
/*!
    @method     - (NSDate*) setTimeOnSameDate:(NSDate*)sameDate
    @abstract   Given a target date, sets the date component (ignoring time) of the receiver to the targ
*/
- (NSDate*) setTimeOnSameDate:(NSDate*)sameDate
{
	
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	const unsigned units    = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* components = [gregorian components:units fromDate:sameDate];
	
	NSInteger todayDay = [components day];
	NSInteger todayMonth = [components month];
	NSInteger todayYear = [components year];
	
	NSDate* retDate = [self setDateForYear:todayYear month:todayMonth day:todayDay];
	
	return retDate;
}

//===========================================================


/*!
    @method     (NSDate*) timeOnNextDay:(NSDate*)theDate
    @abstract   Takes a date and adds a day to it
    @discussion  
*/
- (NSDate*) timeOnNextDay
{
	NSDate* date = [self timeByAddingDays: 1];
	
	return date;

}
//===========================================================
- (NSDate*) timeByAddingDays:(NSInteger)days
{
	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	
	[comps setDay:days];
	
	NSDate* date = [gregorian dateByAddingComponents:comps toDate:self  options:0];
	
	return date;
}

//===========================================================
/*!
    @method     - (NSInteger) dayOfWeek
    @abstract   returns day of week for receiver
    @discussion  
*/
- (NSInteger) dayOfWeek
{

	NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* weekdayComponents =[gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
	NSInteger weekday = [weekdayComponents weekday];

	
	return weekday;
}
//===========================================================
+ (NSDate*) nextTimeFromArray:(NSArray*)dateArray
{
	NSDate* retDate = [dateArray objectAtIndex: 0];
	NSDate* now = [NSDate date];
	now = [now zeroBaseDateForTime];
	
	
	for(NSDate* aDate in dateArray)
	{
		// if its later than now, then this is the one
		if([now compare:aDate] == NSOrderedAscending)
		{
			retDate = aDate;
			break;
		}
	}
	
	
	return retDate;
}
//===========================================================
- (NSArray*) datesTimeSubdividedEndingAt:endRepeatTime subdivided:(NSInteger)numTimes
{
	// set the start time to self and the end time to startTime at end
	NSDate* startTime = [NSDate dateWithTimeInterval:0.0 sinceDate:self];
	NSDate* endTime = [endRepeatTime setTimeOnSameDate:startTime];
	
	//if endTime < startTime
	if([endTime compare:startTime] == NSOrderedAscending)
	{
		endTime = [endTime timeOnNextDay];
	}
	
	
	numTimes = numTimes -1;	// we won't actually use the last interval...keeps the math in check
	
	if([startTime compare:endTime] == NSOrderedDescending)
	{
		endTime = [endTime timeOnNextDay];
	}
	
	// get the time delta
	NSTimeInterval fullDelta = [endTime timeIntervalSinceDate:startTime];
	
	// make subdivided interval
	NSTimeInterval subInterval = fullDelta / ((float) numTimes);
	
	// now create the array
	NSMutableArray* retArray = [[NSMutableArray alloc] init];
	
	// first date
	[retArray addObject:startTime];
	
	// interval dates
	for(int i = 1; i < numTimes; i++)
	{
		NSDate* intervalDate = [NSDate dateWithTimeInterval:(subInterval*(float)i) sinceDate:startTime];
		[retArray addObject:intervalDate];
	}
	
	// last date
	[retArray addObject:endTime];
	
	return((NSArray*) retArray);
	
	
}
//===========================================================
- (NSString*) relativeTimeStr
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *components = [calendar components:unitFlags fromDate:self toDate:[NSDate date] options:0];
	
	NSArray *selectorNames = [NSArray arrayWithObjects:@"year", @"month", @"week", @"day", @"hour", @"minute", @"second", nil];
	
	for (NSString *selectorName in selectorNames) {
		SEL currentSelector = NSSelectorFromString(selectorName);
		NSMethodSignature *currentSignature = [NSDateComponents instanceMethodSignatureForSelector:currentSelector];
		NSInvocation *currentInvocation = [NSInvocation invocationWithMethodSignature:currentSignature];
		
		[currentInvocation setTarget:components];
		[currentInvocation setSelector:currentSelector];
		[currentInvocation invoke];
		
		NSInteger relativeNumber;
		[currentInvocation getReturnValue:&relativeNumber];
		
		if (relativeNumber) {
			return [NSString stringWithFormat:@"%ld%@", (long)relativeNumber, [selectorName substringToIndex:1]];
		}
	}
	
	return @"now";
}


@end

//
//  WRDebugViewController.m
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

#import "WRDebugViewController.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@interface WRDebugViewController ()

@end

@implementation WRDebugViewController

//===========================================================
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//===========================================================
- (void) dealloc
{

	self.searchBar = NULL;
	self.outputLabel = NULL;

}
//===========================================================
- (void)viewDidLoad
{
    [super viewDidLoad];

	
}
//===========================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public methods

//===========================================================
- (void) writeOutput:(NSString*)str
{
	_outputLabel.text = str;
}



#pragma mark - search bar delegate

//=======================================================================================
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	// it works like this...either set a value with like: foobar=blah
	// or run a commmand: playTestSound=YES
	NSString* commandString = searchBar.text;
	NSArray* array = [commandString componentsSeparatedByString: @"="];
	NSString* key = nil;
	NSString* value = nil;
	
	if (array.count == 2) {
		key = [array objectAtIndex:0];
		value = [array objectAtIndex:1];
	} else if (array.count == 1) {
		key = [array objectAtIndex:0];
		value = @"yes";		// commands are represented as "command=YES". We need a value for the key-value pair, but it really doesn't matter what the value is
	}
	
	// convert value to lower case
	value = [value lowercaseString];
	
	BOOL ok = [self handleDebugConsoleKey:key value:value];
	if(!ok) {
		_outputLabel.text = @"COMMAND NOT SUPPORT";
	}

	
}

//===========================================================
- (BOOL) handleDebugConsoleKey:(NSString*)key value:(NSString*)value
{
	return FALSE;
}

@end

//
//  FacebookHelper.h
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

/**
QUICK INTEGRATION GUIDE:

a. hook up app delegate.  You will need to initialize facebook helper, wire up the onActivation message and wire up the url handler.  Then do a login check

b. hook up messages to integrate fb helper to wrbackend in app delegate.  On login, you probably want to add and register the user

c. Hook up a ui messages to login/logout buttons - call openFBReadSession

d. Hookup message handlers for kFacebookHelperNotification_userLoggedIn,kFacebookHelperNotification_userLoggedOut, user needs login as needed
*/



#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

typedef enum
{
	eFBLoginState_null = 0,  // this should never be set explicitly
	
    eFBLoginState_init = 1000,
    eFBLoginState_waitForFBPerms,
    eFBLoginState_startLogin,
    eFBLoginState_needsUserLogin,
    eFBLoginState_waitingForFBLoginToComplete,
    eFBLoginState_loginSuccess,
    eFBLoginState_loginFail,
    eFBLoginState_getFBUserInfo,
    eFBLoginState_userInfoRequestWaiting,
    eFBLoginState_userInfoSuccess,
    eFBLoginState_userInfoFailed,
    eFBLoginState_startFailureRecovery,
    eFBLoginState_userLoggedIn,
    eFBLoginState_complete
} EnumFBLoginState;

#define kFacebookHelperNotification_needsLogin			@"facebook.helper.needs_login"
#define kFacebookHelperNotification_userLoggedIn		@"facebook.helper.user_logged_in"
#define kFacebookHelperNotification_userFailedLogin		@"facebook.helper.user_failed_logged_in"
#define kFacebookHelperNotification_userCanceledLogin	@"facebook.helper.user_canceled_login"
#define kFacebookHelperNotification_userLoggedOut		@"facebook.helper.user_logged_out"

#define kPref_facebookUserId	@"facebook.user_id"
#define kPref_facebookFirstName	@"facebook.first_name"
#define kPref_facebookLastName	@"facebook.last_name"
#define kPref_facebookEmail		@"facebook.email"
#define kPref_facebookGender	@"facebook.gender"
#define kPref_facebookAgeRange	@"facebook.age_range"
#define kPref_facebookLocale	@"facebook.locale"
#define kPref_facebookBirthday	@"facebook.birthday"

typedef enum
{
	eFBRResult_ok = 0,
	eFBRResult_canceled = -1,
	eFBRResult_errNotLogin = -2,
	
	// might want to show an error for these
	eFBRResult_requestFailed = -101,

	
} EnumFBRequestCompletionResult;

typedef void (^FacebookHelperRequestCompletion)(int result, NSURL* resultURL);
typedef void (^FacebookHelperFeedCompletion)(int result);
typedef void (^FacebookHelperLoginCompletion)(int result, BOOL isLoggedIn);
typedef void (^FacebookHelperOpenURLHandler)(NSURL* targetURL);	// url is nil if it no worky

@interface FacebookHelper : NSObject
{

	
	// retained
	NSArray* m_ReadPermissions;

	

	// private
	EnumFBLoginState m_FBLoginState;
	
}

@property (nonatomic, assign, readonly) BOOL mIsFacebookLogin;	// are we logged in?
@property (nonatomic, strong, readonly) NSArray* mReadPermissions;
@property (nonatomic, strong, readonly) NSDictionary* mFriends;


+ (FacebookHelper*) sharedManager;
+ (void) initializeSingletonWithReadPerms:(NSArray*)readPermissions;

//--app "sdk" hooks
- (void) handleAppDidFinishLaunchingWithOptions:(NSDictionary*)options;
- (BOOL) handleAppOpenURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication callback:(FacebookHelperOpenURLHandler)callback;
- (void) handleAppDidBecomeActive;

//--login start

- (void) startFacebookLoginCheck;	// call this to get current fb login.  Will autologin
- (void) openFBReadSession;	// this initiates fb login dialog
- (void) openFBReadSession:(FacebookHelperLoginCompletion)completion;
- (void) facebookLogout;	// This is immediate
- (BOOL) isLoggingIn;

//--feed/request
// These methods check facebook login status and will attempt to log the user in before calling.

// data can have a max 255 char limit
/// Facebook invites and requests
- (void) makeFBRequestWithTitle:(NSString*)title
						message:(NSString*)message
						   data:(NSString*)data
					 completion:(FacebookHelperRequestCompletion)completion;

/// delete a facebook request
- (void) clearFacebookNotification:(NSArray*)requestIdList;

///Facebook feed
- (void) postToFacebookFeedWithTitle:(NSString*)title
								name:(NSString*)caption
								description:(NSString*)description
								iconUrl:(NSString*)iconUrl
								linkUrl:(NSString*)trackedURL
								completion:(FacebookHelperFeedCompletion)completion;

/// comma separated list of friend ids
- (NSString*) getFriendIdList;

/// get the url for the fb profile pic for friend
- (NSURL*) getProfilePicURLForId:(NSString*)fbid;

@end

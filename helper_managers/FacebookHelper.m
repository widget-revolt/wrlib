//
//  FacebookHelper.m
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

#import "FacebookHelper.h"


//iOS only
#ifndef ANDROID

#import <FacebookSDK/FacebookSDK.h>

#import "WRUtils.h"
#import "WRLogging.h"
#import "NSString+WRAdditions.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

static FacebookHelper* gSharedInstance_FacebookHelper = nil;

//////////////////////////////////////////////////////////////////////////
@interface FacebookHelper ()
{

	FBFrictionlessRecipientCache* m_FriendsCache;


}

// blocks
@property (readwrite, nonatomic, copy) FacebookHelperLoginCompletion bLoginCompletionCallback;

// private
@property (nonatomic, assign, readwrite) BOOL mIsFacebookLogin;	// are we logged in?
@property (nonatomic, strong, readwrite) NSArray* mReadPermissions;
@property (nonatomic, strong, readwrite) NSDictionary* mFriends;


@property (nonatomic, strong) FBFrictionlessRecipientCache* mFriendsCache;


@end


//////////////////////////////////////////////////////////////////////////
@implementation FacebookHelper


#pragma mark - Object lifecycle
//==============================================================
+ (FacebookHelper*) sharedManager
{
	static dispatch_once_t onceQueue;
	
    dispatch_once(&onceQueue, ^{
        gSharedInstance_FacebookHelper = [[FacebookHelper alloc] init];
    });
	
    return gSharedInstance_FacebookHelper;
}

//===========================================================
+ (void) initializeSingletonWithReadPerms:(NSArray*)readPermissions
{
	FacebookHelper* fbHelper = [FacebookHelper sharedManager];
	fbHelper.mReadPermissions = readPermissions;
}
//==============================================================
- (id) init
{
	if( (self = [super init]) )
	{
		self.mIsFacebookLogin = FALSE;
		m_FBLoginState = eFBLoginState_init;
		
		self.mReadPermissions = [NSArray array];
		self.mFriends = [NSDictionary dictionary];


		self.mFriendsCache = NULL;


		self.bLoginCompletionCallback = NULL;
		
		
	}
	
	return self;
}

//==============================================================
- (void) dealloc
{
	self.mReadPermissions = NULL;
	self.mFriends = NULL;
	self.mFriendsCache = NULL;

	self.bLoginCompletionCallback = NULL;

}

#pragma mark - Public Utils


//==============================================================
- (void) loadFriends
{
	__block __typeof__(self) bself = self;
	[FBRequestConnection startForMyFriendsWithCompletionHandler:
		^(FBRequestConnection *connection, id result, NSError *error)
		 {
			 if(!result || error)
			 {
				 WRErrorLog(@"Error while fetching FB friends: %@", error);
				 return;
			 }

			 bself.mFriends = result;


		 }];

	// create a friends cache while we're at it
	self.mFriendsCache = [[FBFrictionlessRecipientCache alloc] init];
	[_mFriendsCache prefetchAndCacheForSession:nil];

}

//===========================================================
- (NSString*) getFriendIdList
{
	NSString* retStr = @"";
	NSArray* friendObjList = [_mFriends objectForKey:@"data"];
	if(!friendObjList || [friendObjList count] == 0) {
		return retStr;
	}
	
	NSMutableArray* idList = [NSMutableArray array];
	for(NSDictionary* friend in friendObjList)
	{
		NSString* fbid = friend[@"id"];
		[idList addObject:fbid];
	}
	
	retStr = [idList componentsJoinedByString:@","];
	return retStr;
}


#pragma mark - Facebook Requests


//===========================================================
- (void) postToFacebookFeedWithTitle:(NSString*)title
								name:(NSString*)name
						 description:(NSString*)description
							 iconUrl:(NSString*)iconUrl
							 linkUrl:(NSString*)linkUrl
						  completion:(FacebookHelperFeedCompletion)completion
{
	__block __typeof__(self) bself = self;
	
	// if we are not logged in, we need to start a login and then run the request on completion
	if(!_mIsFacebookLogin)
	{
		[self openFBReadSession:^(int result, BOOL isLoggedIn)
		 {
			 if(!isLoggedIn)
			 {
				 WRDebugLog(@"Facebook feed dialog failed.  User not logged in");
				 completion(eFBRResult_errNotLogin);
				 return;
			 }
			 
			 [bself postToFacebookFeedInner:title name:name description:description iconUrl:iconUrl linkUrl:linkUrl completion:completion];
		 }];
	}
	else
	{
		[bself postToFacebookFeedInner:title name:name description:description iconUrl:iconUrl linkUrl:linkUrl completion:completion];
	}
}

//===========================================================
- (void) postToFacebookFeedInner:(NSString*)title
								name:(NSString*)name
						 description:(NSString*)description
							 iconUrl:(NSString*)iconUrl
							 linkUrl:(NSString*)linkUrl
						  completion:(FacebookHelperFeedCompletion)completion
{

	// Prepare the native share dialog parameters
    FBShareDialogParams* shareParams = [[FBShareDialogParams alloc] init];
    shareParams.link = [NSURL URLWithString:linkUrl];
    shareParams.name = title;
    shareParams.caption= name;
    shareParams.picture= [NSURL URLWithString:iconUrl];
    shareParams.description = description;
	
    if ([FBDialogs canPresentShareDialogWithParams:shareParams])
	{
		
        [FBDialogs presentShareDialogWithParams:shareParams
                                    clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
										{
										
											if(error)
											{
												// Case A: Error launching the dialog or sending request.
												WRDebugLog(@"feed request error: %@", error);
												completion(eFBRResult_requestFailed);
											}
											else
											{
												if (results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"])
												{
													// Case B: User clicked the "x" icon
													WRDebugLog(@"User canceled feed request.");
													completion(eFBRResult_canceled);
												}
												else
												{
													WRDebugLog(@"Request Sent.");
													completion(eFBRResult_ok);
												}
											}
										
             
                                        }];
		
    }
	else
	{
		
        // Prepare the web dialog parameters
        NSDictionary* params = @{
                                 @"name" : shareParams.name,
                                 @"caption" : shareParams.caption,
                                 @"description" : shareParams.description,
                                 @"picture" : iconUrl,
                                 @"link" : linkUrl
                                 };
		
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
			^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
			{
				if(error)
				{
					// Case A: Error launching the dialog or sending request.
					WRDebugLog(@"feed request error: %@", error);
					completion(eFBRResult_requestFailed);
				}
				else
				{
					if (result == FBWebDialogResultDialogNotCompleted)
					{
						// Case B: User clicked the "x" icon
						WRDebugLog(@"User canceled feed request.");
						completion(eFBRResult_canceled);
					}
					else
					{
						WRDebugLog(@"Request Sent.");
						completion(eFBRResult_ok);
					}
				}
			
			}];
    }

}

//===========================================================
- (NSURL*) getProfilePicURLForId:(NSString*)fbid
{
	NSString* retStr = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", fbid];
	
	NSURL* url = [NSURL URLWithString:retStr];
	return url;
}

//===========================================================
- (void) makeFBRequestWithTitle:(NSString*)title
						message:(NSString*)message
						   data:(NSString*)data
					 completion:(FacebookHelperRequestCompletion)completion
{
	__block __typeof__(self) bself = self;

	// if we are not logged in, we need to start a login and then run the request on completion
	if(!_mIsFacebookLogin)
	{
		[self openFBReadSession:^(int result, BOOL isLoggedIn)
		{
			if(!isLoggedIn)
			{
				WRDebugLog(@"Facebook request dialog failed.  User not logged in");
				completion(eFBRResult_errNotLogin, NULL);
				return;
			}
			
			[bself makeFBRequestWhenLoggedIn:title message:message data:data completion:completion];
		}];
	}
	else
	{
		[self makeFBRequestWhenLoggedIn:title message:message data:data completion:completion];
	}
}

//===========================================================
- (void) makeFBRequestWhenLoggedIn:(NSString*)title
						   message:(NSString*)message
							  data:(NSString*)data
						completion:(FacebookHelperRequestCompletion)completion
{


	WRDebugLog(@"making fb request");
	
	//__block __typeof__(self) bself = self;
	
	NSDictionary* params = NULL;

	
	if(data)
	{
		params = @{
			@"data": data,

			
		};
	}


	[FBWebDialogs presentRequestsDialogModallyWithSession:nil
												  message:message
													title:title
											   parameters:params
												  handler:
		^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
			if(error)
			{
			  // Case A: Error launching the dialog or sending request.
			  completion(eFBRResult_requestFailed, resultURL);
			}
			else
			{
				if (result == FBWebDialogResultDialogNotCompleted)
				{
					// Case B: User clicked the "x" icon
					WRDebugLog(@"User canceled fbrequest.");
					completion(eFBRResult_canceled, resultURL);
				}
				else
				{
					WRDebugLog(@"Request Sent.");
					completion(eFBRResult_ok, resultURL);
				}
			}
		}
		friendCache:_mFriendsCache];
		

}

//===========================================================
- (void) clearFacebookNotification:(NSArray*)requestIdList
{
   for(NSString* requestId in requestIdList)
   {
	   [self clearFacebookNotificationByRequestId:requestId];
   }
}
//===========================================================
- (void) clearFacebookNotificationByRequestId:(NSString*)requestId
{
	NSString* bRequestId = requestId;

	// Delete the request notification
    [FBRequestConnection startWithGraphPath:bRequestId
								 parameters:nil
								 HTTPMethod:@"DELETE"
						  completionHandler:^(FBRequestConnection *connection,
											  id result,
											  NSError *error) {
							  if (!error) {
								  WRInfoLog(@"FB Request deleted");
							  }
							  else
							  {
								  WRErrorLog(@"Error deleting fb request: %@", error);
							  }
						  }];
}

#pragma mark - Login common


//==============================================================
// gets called on app launch
- (void) handleAppDidFinishLaunchingWithOptions:(NSDictionary*)options
{
	if(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
	{
		// TO IMPLEMENT: any custom code
	}
	else
	{
		// user is not logged in
		// TO IMPLEMENT: any custom code
	}
}
//==============================================================
- (BOOL) handleAppOpenURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication callback:(FacebookHelperOpenURLHandler)callback
{
	BOOL ok = FALSE;


	ok = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
		if (call.appLinkData && call.appLinkData.targetURL)
		{
			callback(call.appLinkData.targetURL);
		}
	}];

	///old way --> return [FBSession.activeSession handleOpenURL:url];


	return ok;
}
//==============================================================
- (void) handleAppDidBecomeActive
{
	// close our session and start over IF we canceled login on fb app
	if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        // Facebook sample - production code should close a
        // session in the opening state on transition back to the application; this line will again be
        // active in the next production rev
		[FBSession.activeSession close]; // so we close our session and start over
		
    }

	[FBSession.activeSession handleDidBecomeActive];
}

#pragma mark - session state block
//==============================================================
- (void)sessionStateChanged:(FBSession*)session
                      state:(FBSessionState)state
                      error:(NSError*)error
{
    WRDebugLog(@"FB sessionStateChanged: sessionStateChanged -- activeSession null?: %@", (FBSession.activeSession == NULL ? @"yes" : @"no"));
    if(state == FBSessionStateCreated)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateCreated");
    }
    else if(state == FBSessionStateCreatedTokenLoaded)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateCreatedTokenLoaded");
    }
    else if(state == FBSessionStateCreatedOpening)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateCreatedOpening");
    }
    else if(state == FBSessionStateOpen)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateOpen");
    }
    else if(state == FBSessionStateOpenTokenExtended)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateOpenTokenExtended");
    }
    else if(state == FBSessionStateClosedLoginFailed)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateClosedLoginFailed");
    }
    else if(state == FBSessionStateClosed)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateClosed");
    }
    
	// canceled login?  This will get set in didBecomeActive (see FB docs)
	// Check this before checking for errors
	if(state == FBSessionStateClosedLoginFailed)
	{
		// Tell UI that user canceled
		[[NSNotificationCenter defaultCenter] postNotificationName:kFacebookHelperNotification_userCanceledLogin object:self];
        
        [FBSession.activeSession closeAndClearTokenInformation];
        
        [self doFacebookLoginState:eFBLoginState_loginFail];
        return;
	}
	
    // Now check for errors
    if(error)
    {
        WRErrorLog(@"FB sessionStateChanged: ERROR Occurred: %@", error);
        
		// notify UI
        [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookHelperNotification_userFailedLogin object:self];
        
		// we failed - celar the token info
        [FBSession.activeSession closeAndClearTokenInformation];
        
		// update the state machine
        [self doFacebookLoginState:eFBLoginState_loginFail];
		
        return; //<==EXIT
    }
    
	// Were we opened ?
    if(state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateOpen or FBSessionStateOpenTokenExtended - logged in");

#if DEBUG
		// print out any debug info that requires an active session
        NSString* facebookAppId = FBSession.activeSession.appID;
        WRDebugLog(@"Using facebook app id: %@", facebookAppId);
#endif

		// If we are open (but not extended) then report successful.  It is possible to get the "Extended" state when the token is refreshed, which would cause this code to get executed twice.  Don't do that.
		if(state == FBSessionStateOpen)
		{
			// We're successful
			[self doFacebookLoginState:eFBLoginState_loginSuccess];
		}
		
    }
    else if(state == FBSessionStateClosedLoginFailed || state == FBSessionStateClosed)
    {
        WRDebugLog(@"FB sessionStateChanged: FBSessionStateClosedLoginFailed or FBSessionStateClosed - not logged in");

        
        // notify ui of the situation
        [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookHelperNotification_userLoggedOut object:self];
        
        [FBSession.activeSession closeAndClearTokenInformation];

    }
}


#pragma mark - Login statemachine

//===========================================================
- (BOOL) isLoggingIn
{
	if(m_FBLoginState == eFBLoginState_complete) {
		return FALSE;
	}
	
	return TRUE;
}

//===========================================================
- (void) startFacebookLoginCheck:(FacebookHelperLoginCompletion)completion
{
	self.bLoginCompletionCallback = completion;
	
	[self startFacebookLoginCheck];
}

//==============================================================
- (void) startFacebookLoginCheck
{
	[self doFacebookLoginState:eFBLoginState_init];
}

//==============================================================
- (void) doFacebookLoginState:(EnumFBLoginState)newState
{
	BOOL continueState = FALSE;
    int nextState;
    
    // transition?
    if(newState != eFBLoginState_null) {
        m_FBLoginState = newState;
    }
    
    do
    {
        continueState = FALSE;
		
        switch(m_FBLoginState)
        {
			case eFBLoginState_null:
			break;
		
            case eFBLoginState_init:
            {
                WRDebugLog(@"FBState: state = eFBLoginState_init");
                [self doGetFBPermissions];
				
				//-->transition
                m_FBLoginState = eFBLoginState_waitForFBPerms;
            }
			break;
			
			case eFBLoginState_waitForFBPerms:
				WRDebugLog(@"FBState: state = eFBLoginState_waitForFBPerms");
			break;
			
			case eFBLoginState_startLogin:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_startLogin");
                nextState = [self doFacebookStartLogin];
				
				//-->transition
                m_FBLoginState = nextState;
                continueState = TRUE;	// continue on
			}
			break;
			
			case eFBLoginState_needsUserLogin:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_needsUserLogin");
                [self doFacebookNeedsLoginState];

				//-->transition
				m_FBLoginState = eFBLoginState_complete;
				continueState = TRUE;	// continue on
			}
			break;
			
			case eFBLoginState_waitingForFBLoginToComplete:
				// wait state
				WRDebugLog(@"FBState: state = eFBLoginState_waitingForFBLoginToComplete");
			break;
			
			case eFBLoginState_loginFail:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_loginFail");
				
				//-->transition
                m_FBLoginState = eFBLoginState_needsUserLogin;
                continueState = TRUE;
			}
			break;
			
			case eFBLoginState_loginSuccess:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_loginSuccess");
				
				// load the users friends.  We want them later for other requests
				[self loadFriends];
				
				//-->transition
                m_FBLoginState = eFBLoginState_getFBUserInfo;
                continueState = TRUE;
			}
			break;
			
			case eFBLoginState_getFBUserInfo:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_getFBUserInfo");
				
				// request the user info - make sure we do this on the next event loop
				[self performSelector:@selector(getFacebookUserInfo) withObject:nil afterDelay:0.1];
				
				//-->transition
				m_FBLoginState = eFBLoginState_userInfoRequestWaiting;
                continueState = TRUE;
			}
			break;
			
			case eFBLoginState_userInfoRequestWaiting:
			break;
			
			case eFBLoginState_userInfoSuccess:
			{
                WRDebugLog(@"FBState: state = eFBLoginState_userInfoSuccess");
                
                [self performSelector:@selector(doUserLoggedIn) withObject:nil afterDelay:0.1];
            }
			break;
				
			case eFBLoginState_userInfoFailed:
			{
                WRDebugLog(@"FBState: state = eFBLoginState_userInfoFailed");
               
				//-->transition
                m_FBLoginState = eFBLoginState_startFailureRecovery;
                continueState = TRUE;
            }
			break;
			
			case eFBLoginState_startFailureRecovery:
			{
				
				WRDebugLog(@"FBState: state = eFBLoginState_startFailureRecovery");
                
				// logout facebook
				[self facebookLogout];
				
                //-->transition
                m_FBLoginState = eFBLoginState_loginFail;
                continueState = TRUE;
			}
			break;
			
			case eFBLoginState_userLoggedIn:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_userLoggedIn");
				
				// and now we are logged in
				self.mIsFacebookLogin = TRUE;
				
				// post a notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookHelperNotification_userLoggedIn object:self];

                
				//-->transition
                m_FBLoginState = eFBLoginState_complete;
				continueState = TRUE;
				
			}
			break;
			
			case eFBLoginState_complete:
			{
				WRDebugLog(@"FBState: state = eFBLoginState_complete");
				
				if(_bLoginCompletionCallback)
				{
					_bLoginCompletionCallback(0, _mIsFacebookLogin);
					self.bLoginCompletionCallback = NULL;
				}
			}
			break;
		}
	}
	while(continueState);

}

//==============================================================
- (void) doGetFBPermissions
{
	// if we want to get permissions from HTTP, do it here, else just fit in with the async nature and post a callback asynchronously
	// This is a future hook opened for expansion so that we can do this from a server later
//	self.mReadPermissions = @[
//		@"email",
//		@"user_birthday",
//	];
	
	[self performSelector:@selector(onReceiveFBPermissions:) withObject:NULL afterDelay:0.01f];
	
}
//==============================================================
- (void) onReceiveFBPermissions:(id)obj
{
	[self doFacebookLoginState:eFBLoginState_startLogin];
}
//==============================================================
- (EnumFBLoginState) doFacebookStartLogin
{
	WRDebugLog(@"FB login: doFacebookStartLogin...");

    // if we already have an open session then continue on, else we need to login
    EnumFBLoginState retValue = eFBLoginState_waitingForFBLoginToComplete;
	
    if(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        // always open the session now
        [self openFBReadSession];
    }
    else
    {
        retValue = eFBLoginState_needsUserLogin;
    }
    
    
    return retValue;
}
//===========================================================
- (void) openFBReadSession:(FacebookHelperLoginCompletion)completion
{
	self.bLoginCompletionCallback = completion;
	[self openFBReadSession];
}
//==============================================================
- (void) openFBReadSession
{
    WRDebugLog(@"FB login: openFBReadSession - activeSession nil?: %@", (FBSession.activeSession == nil ? @"Yes" : @"No"));
	
	// if we have an active session, then we need to explicitly clear it here before we reopen
    if (FBSession.activeSession)
    {
        FBSession.activeSession = NULL;
    }
	
	// now open with read perms
    BOOL ok = [FBSession openActiveSessionWithReadPermissions:_mReadPermissions
												 allowLoginUI:TRUE
											completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
												[self sessionStateChanged:session
																	state:state
																	error:error];
											}];
	#pragma unused(ok)
	WRDebugLog(@"FB login: openActiveSession result: %d", ok);
}
//==============================================================
- (void) getFacebookUserInfo
{
	[FBRequestConnection startForMeWithCompletionHandler:
		^(FBRequestConnection* connection, id result, NSError* error)
		 {
	
			 if(error)
			 {
				 WRErrorLog(@"fb login Error: Facebook user info request failed with error: %@", error);
				 [self doFacebookLoginState:eFBLoginState_userInfoFailed];
			 }
			 else
			 {
				 WRDebugLog(@"fb login: user info retrieved");
				 
				 // get the info we need from facebook
				 NSDictionary* dictResult = (NSDictionary*) result;
				 NSString* userID = [dictResult objectForKey:@"id"];
				 NSString* firstName = [dictResult objectForKey:@"first_name"];
				 NSString* lastName = [dictResult objectForKey:@"last_name"];
				 NSString* gender = [dictResult objectForKey:@"gender"];
				 NSString* locale = [dictResult objectForKey:@"locale"];
				 NSString* email = [dictResult objectForKey:@"email"];
				 NSString* birthday = [dictResult objectForKey:@"birthday"];
		
				 
				 if([NSString isEmptyString:userID])
				 {
	#if DEBUG
					// Throw up an alert for the kids/developers at home
					 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Developer Error"
														 message:@"Unable to login to facebook.  Make sure you have a the correct app id.  This is a debug message only"
														delegate:self
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:nil];
					[alertView show];
	#endif
	
					 WRErrorLog(@"FB login: Error retrieving userinfo.  Data returned, but does not contain username or user id:%@", error);
					 
					 [self doFacebookLoginState:eFBLoginState_userInfoFailed];
					 
				 }
				 else
				 {
					 // save it some well known keys in the prefs
					 NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
					 
					 [defaults setObject:userID forKey:kPref_facebookUserId];
					 [defaults setObject:firstName forKey:kPref_facebookFirstName];
					 [defaults setObject:lastName forKey:kPref_facebookLastName];
					 [defaults setObject:gender forKey:kPref_facebookGender];
					// [defaults setObject:ageRange forKey:kPref_facebookAgeRange];
					 [defaults setObject:locale forKey:kPref_facebookLocale];
					 [defaults setObject:email forKey:kPref_facebookEmail];
					 [defaults setObject:birthday forKey:kPref_facebookBirthday];

					 
					 [defaults synchronize];
					 
					 // we're done
					 [self doFacebookLoginState:eFBLoginState_userInfoSuccess];
				 }
			 }
		 }];


}
//==============================================================
- (void) doUserLoggedIn
{
	WRDebugLog(@"FBHelper doUserLoggedIn - FBSession.activeSession.isOpen?: %@", (FBSession.activeSession.isOpen ? @"Yes" :@"No"));

    if(FBSession.activeSession.isOpen)
    {
        [self doFacebookLoginState:eFBLoginState_userLoggedIn];
        
    }
    else
    {
        WRDebugLog(@"fb login: user logged in but session invalid...back to needing user login");
        [self doFacebookLoginState:eFBLoginState_needsUserLogin];
    }

}
//==============================================================
- (void) facebookLogout
{
	WRDebugLog(@"FB Helper logout");

    
	// immedate logout
	self.mIsFacebookLogin = FALSE;
    
    if (FBSession.activeSession.isOpen)
    {
        WRDebugLog(@"FB logout: closeAndClearTokenInformation");
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else
    {
        WRDebugLog(@"FB logout: already logged out");
    }
}
//==============================================================
- (void) doFacebookNeedsLoginState
{
	// exit - we need to login to facebook.
	self.mIsFacebookLogin = FALSE;
	
	// post a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kFacebookHelperNotification_needsLogin object:self];
}

@end

#endif //if !ANDROID
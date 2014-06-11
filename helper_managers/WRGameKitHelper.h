//
//  WRGameKitHelper.h
//  WRLib
//
//  Created by bchen on 1/2/14.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

//#define kWRGameKitHelper_secretKey	@"MySecretKeyHere"		<-- Define this in your own constants
#define kWRGameKitHelperNotif_userLoggedIn			@"wrgamekithelper.user_logged_in"
#define kWRGameKitHelperNotif_userFailedLoggedIn	@"wrgamekithelper.user_failed_login"

#define kPref_gamecenterUserId	@"gamecenter.id"
#define kPref_gamecenterAlias	@"gamecenter.alias"
#define kPref_gamecenterDisplayName	@"gamecenter.display_name"

@protocol WRGameKitHelperDelegate;

@interface WRGameKitHelper : NSObject

+ (id) sharedManager;

- (void) startAuthentication:(NSString*)secretKey;	// call this when you are ready to start authentication

/// leaderboard
-(void) reportScore:(long long)aScore forLeaderboard:(NSString*)leaderboardId;

/// achievements
-(void) reportAchievementWithID:(NSString*)achievementId percentComplete:(double)percent;
-(void) resetAchievements;
-(BOOL) hasCompletedAchievement:(NSString*)achievementId;

/// notifications
-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)achievementId;

/// friend ids
- (NSString*) getFriendIdList;


@property (weak) id<WRGameKitHelperDelegate> delegate;
@property (nonatomic, assign, readonly)	BOOL mAuthenticated;

@end


@protocol WRGameKitHelperDelegate

@optional
- (void) showGameKitAuthUI:(UIViewController*)viewController;
- (void) authStatusChanged:(BOOL)authenticated forLocalPlayer:(GKLocalPlayer*)player;
- (void) onAchievementReported:(GKAchievement*)achievement isNew:(BOOL)isNew;

@end

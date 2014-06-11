//
//  WRGameKitHelper.m
//
//  Created by bchen on 1/2/14.
//	Copyright (c) 2014 Widget Revolt, LLC
//  Copyright (c) 2013 Alexander Blunck | Ablfx (which was obviously derived from Stefen Itterheim)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//
//

#import "WRGameKitHelper.h"

#import "WRReachability.h"
#import "WRLogging.h"



#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

//iOS implementation
#ifndef ANDROID

#import <CommonCrypto/CommonCryptor.h>

//////////////////////////////////////////////////////////////////
@interface WRGameKitHelper()

@property (nonatomic, strong) NSString* mSecretKey;

@property (nonatomic, assign, readwrite)	BOOL mAuthenticated;

@property (nonatomic, strong) GKLocalPlayer* mLocalPlayer;
@property (nonatomic, strong) NSArray* mFriendIdList;

@end

//////////////////////////////////////////////////////////////////
@implementation WRGameKitHelper

#pragma mark - singleton

//===========================================================
+ (WRGameKitHelper*) sharedManager
{
	static WRGameKitHelper* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WRGameKitHelper alloc] init];
    });
    
    return _sharedClient;
}

#pragma mark - lifecycle

//===========================================================
- (id) init
{
	self = [super init];
	if(self)
	{
		self.mSecretKey = @"SET THE SECRET KEY in startAuth";
		self.mLocalPlayer = NULL;
		self.mFriendIdList = [NSArray array];
	}
	
	return self;
}

//===========================================================
- (void) startAuthentication:(NSString*)secretKey
{

	self.mSecretKey = secretKey;

    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	
    __block __typeof__(self) bself = self;
	__weak GKLocalPlayer* bLocalPlayer = localPlayer;
	
	// this will kick off authentication
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
	{
        
        if (viewController)
        {
			[bself showGameKitAuthUI:viewController];
           
        }
        else if(bLocalPlayer.isAuthenticated)
        {
			[bself onLocalPlayerIsAuthenticated:bLocalPlayer error:error];
        }
		else
		{
			[bself onLocalPlayerFailedAuthenticate:bLocalPlayer error:error];
		}

    };//end ^authBlock


}
//===========================================================
- (void) showGameKitAuthUI:(UIViewController*)viewController
{

	if([(NSObject*)_delegate respondsToSelector:@selector(showGameKitAuthUI:)])
	{
		[_delegate showGameKitAuthUI:viewController];
	}
}
//===========================================================
- (void) onLocalPlayerIsAuthenticated:(GKLocalPlayer*)localPlayer error:(NSError*)error
{

	WRDebugLog(@"WRGameKitHelper: Player authenticted in gamekit");
	
	self.mAuthenticated = YES;
	self.mLocalPlayer = localPlayer;
	
	//Report possible cached scores / achievements
	[self reportCachedAchievements];
	[self reportCachedScores];
	
	// tell the delegate
	if([(NSObject*)_delegate respondsToSelector:@selector(authStatusChanged:forLocalPlayer:)])
	{
		[_delegate authStatusChanged:YES forLocalPlayer:localPlayer];
	}
	
	// Broadcast
	[[NSNotificationCenter defaultCenter] postNotificationName:kWRGameKitHelperNotif_userLoggedIn object:localPlayer];
	
	// start retreiving friends
	__block __typeof__(self) bself = self;
	[_mLocalPlayer loadFriendsWithCompletionHandler:^(NSArray *friendIDs, NSError *error) {
		if(friendIDs) {
			[bself setFriendIds:friendIDs];
		}
		else {
			WRErrorLog(@"Error getting gklocalplayer friends: %@", error);
		}
	}];
	

}
//===========================================================
- (void) onLocalPlayerFailedAuthenticate:(GKLocalPlayer*)localPlayer error:(NSError*)error
{

	self.mAuthenticated = NO;
	WRInfoLog(@"WRGameKitHelper:  Player failed to authenticate: Error = %@", error);
	
	// tell the delegate
	if([(NSObject*)_delegate respondsToSelector:@selector(authStatusChanged:forLocalPlayer:)])
	{
		[_delegate authStatusChanged:NO forLocalPlayer:localPlayer];
	}
	
	// Broadcast
	[[NSNotificationCenter defaultCenter] postNotificationName:kWRGameKitHelperNotif_userFailedLoggedIn object:error];

}

#pragma mark - friend ids

//===========================================================
- (void) setFriendIds:(NSArray*)friendIDs
{
	self.mFriendIdList = friendIDs;
}

//===========================================================
- (NSString*) getFriendIdList
{
	NSString* retStr = @"";
	NSArray* friendObjList = _mFriendIdList;
	if(!friendObjList || [friendObjList count] == 0) {
		return retStr;
	}

	
	retStr = [_mFriendIdList componentsJoinedByString:@","];
	return retStr;
}

#pragma mark - Achievements

//===========================================================
- (BOOL) hasCompletedAchievement:(NSString*)achievementId
{
	BOOL isDone = [self boolForKey:achievementId];
	return isDone;
}
//===========================================================
-(void) reportAchievementWithID:(NSString*)achievementId percentComplete:(double)percent
{

    if (percent > 100.0f) percent = 100.0f;
    
    //Mark achievement as completed locally
	BOOL hasCurrent = [self hasCompletedAchievement:achievementId];
	BOOL isNew = FALSE;
	
    if (percent == 100)
	{
        [self saveBool:YES key:achievementId];
		if(!hasCurrent) {
			isNew = TRUE;
		}
    }

	
    __block __typeof__(self) bself = self;
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    
    if (achievement)
    {
        achievement.percentComplete = percent;
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (!error)
            {
                
                WRDebugLog(@"WRGameKitHelper: Achievement (%@) with %f%% progress reported", achievement.identifier, achievement.percentComplete);
				
				[bself onAchievementReported:achievement isNew:isNew];
            }
            else
            {
                [self cacheAchievement:achievement];
                WRErrorLog(@"WRGameKitHelper: ERROR -> Reporting achievement (%@) with %f%% progress failed, caching...Error=%@", achievement.identifier, achievement.percentComplete, error);
            }
        }];
    }


}
//===========================================================
- (void) onAchievementReported:(GKAchievement*)achievement isNew:(BOOL)isNew
{
	if([(NSObject*)_delegate respondsToSelector:@selector(onAchievementReported:isNew:)])
	{
		[_delegate onAchievementReported:achievement isNew:isNew];
	}
}

////===========================================================
//-(void) showAchievements
//{
//    GKAchievementViewController *viewController = [GKAchievementViewController new];
//    viewController.achievementDelegate = self;
//    
//    [[self topViewController] presentViewController:viewController animated:YES completion:nil];
//}
//===========================================================
-(void) resetAchievements
{

	// clear all cached achievements and completions
	[self clearData];

    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (!error)
        {
            WRInfoLog(@"WRGameKitHelper: Achievements reset successfully.");
        }
        else
        {
            WRInfoLog(@"WRGameKitHelper: Failed to reset achievements.");
        }
    }];

}

#pragma mark - Leaderboard

//===========================================================
-(void) reportScore:(long long)aScore forLeaderboard:(NSString*)leaderboardId
{

    GKScore *score = [[GKScore alloc] initWithCategory:leaderboardId];
    score.value = aScore;
    
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        if (!error)
        {
            if(![WRReachability hasConnectivity])
            {
                [self cacheScore:score];
            }
            WRDebugLog(@"WRGameKitHelper: Reported score (%lli) to %@ successfully.", score.value, leaderboardId);
        }
        else
        {
            [self cacheScore:score];
            WRErrorLog(@"WRGameKitHelper: ERROR -> Reporting score (%lli) to %@ failed, caching... Error=%@", score.value, leaderboardId, error);
        }
    }];

}

#pragma mark - Notifications


//===========================================================
-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)achievementId
{

    //Show notification only if it hasn't been achieved yet
    if (![self boolForKey:achievementId])
    {
        [GKNotificationBanner showBannerWithTitle:title message:message completionHandler:nil];
    }

}

////===========================================================
//-(void) showLeaderboard:(NSString*)leaderboardId
//{
//    GKLeaderboardViewController *viewController = [GKLeaderboardViewController new];
//    viewController.leaderboardDelegate = self;
//    if (leaderboardId)
//    {
//        viewController.category = leaderboardId;
//    }
//    
//    [[self topViewController] presentViewController:viewController animated:YES completion:nil];
//}

#pragma mark - achievement caching

//===========================================================
- (void) cacheAchievement:(GKAchievement*)achievement
{

    //Retrieve cached achievements
    NSMutableArray* achievements;
    if(![self objectForKey:@"cachedAchievements"])
    {
        achievements = [NSMutableArray new];
    }
    else
    {
        achievements = [self objectForKey:@"cachedAchievements"];
    }
    
    //Add new achievment to array
    [achievements addObject:achievement];
    
    //Save achievement to persistant storage
    [self saveObject:achievements key:@"cachedAchievements"];

}

//===========================================================
- (void) reportCachedAchievements
{

    //Retrieve cached achievements
    NSMutableArray *achievements = [self objectForKey:@"cachedAchievements"];
    
    if (achievements.count == 0) {
        return;
    }
    
    WRDebugLog(@"WRGameKitHelper: Attempting to report %lu cached achievements...", (unsigned long)achievements.count);
    
	// ios 6+ only
	__block __typeof__(self) bself = self;
	[GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
		if (!error)
		{
			[bself removeAllCachedAchievements];
			WRDebugLog(@"WRGameKitHelper: Reported %lu cached achievement(s) successfully.", (unsigned long)achievements.count);
		}
		else
		{
			WRErrorLog(@"WRGameKitHelper: ERROR -> Failed to report %lu cached achievement(s). Error=%@", (unsigned long)achievements.count, error);
		}
	}];

}
//===========================================================
-(void) removeCachedAchievement:(GKAchievement*)achievement
{

    NSMutableArray *achievements = [self objectForKey:@"cachedAchievements"];
    [achievements removeObject:achievement];
    [self saveObject:achievements key:@"cachedAchievements"];

}
//===========================================================
-(void) removeAllCachedAchievements
{

    [self saveObject:[NSMutableArray new] key:@"cachedAchievements"];

}

#pragma mark - Score caching



//===========================================================
-(void) cacheScore:(GKScore*)aScore
{

    //Retrieve cached scores
    NSMutableArray *scores;
    if(![self objectForKey:@"cachedScores"])
    {
        scores = [NSMutableArray new];
    }
    else
    {
        scores = [self objectForKey:@"cachedScores"];
    }
    
    //Add new score to array
    [scores addObject:aScore];
    
    //Save scores to persistant storage
    [self saveObject:scores key:@"cachedScores"];

}
//===========================================================
-(void) reportCachedScores
{

    //Retrieve cached scores
    NSMutableArray *scores = [self objectForKey:@"cachedScores"];
    
    if (scores.count == 0)
    {
        return;
    }
    
    WRDebugLog(@"WRGameKitHelper: Attempting to report %lu cached scores...", (unsigned long)scores.count);
    
    //iOS 6.x+
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
		if (!error)
		{
			[self removeAllCachedScores];
			WRDebugLog(@"WRGameKitHelper: Reported %lu cached score(s) successfully.", (unsigned long)scores.count);
		}
		else
		{
			WRErrorLog(@"WRGameKitHelper: ERROR -> Failed to report cached score(s). Error=%@", error);
		}
	}];

}
//===========================================================
-(void) removeCachedScore:(GKScore*)score
{

    NSMutableArray *scores = [self objectForKey:@"cachedScores"];
    [scores removeObject:score];
    [self saveObject:scores key:@"cachedScores"];

}
//===========================================================
-(void) removeAllCachedScores
{

    [self saveObject:[NSMutableArray new] key:@"cachedScores"];

}

#pragma mark - Data persistence

//===========================================================
-(NSString*) filePath
{
    NSString* fileExt = @".wrgk";
	NSString* bundlePath = [[[NSBundle mainBundle] bundleURL] lastPathComponent];
    NSString* appName = [[bundlePath stringByDeletingPathExtension] lowercaseString];
	
    NSString* fileName = [NSString stringWithFormat:@"%@%@", [appName lowercaseString], fileExt];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    return path;
}
//===========================================================
- (NSMutableDictionary*) dataDictionary
{
    NSData *binaryFile = [NSData dataWithContentsOfFile:[self filePath]];
    NSMutableDictionary *dictionary = nil;
    
    if (binaryFile == nil)
    {
        dictionary = [NSMutableDictionary dictionary];
    }
    else
    {
        NSData *decryptedData = [self decryptData:binaryFile withKey:_mSecretKey];
		
		//We probably should get rid of data decryption, but if there was a problem with the data, then just create a clean dict
		@try {
			dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
		} @catch(...) {
			WRErrorLog(@"Error decrypting data");
			dictionary = NULL;
		}
		
		if(dictionary == NULL) {
			dictionary = [NSMutableDictionary dictionary];
		}
    }
    
    return dictionary;
}

//===========================================================
- (void) saveData:(NSData*)data key:(NSString*)key
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self filePath]];
    NSMutableDictionary *tempDic = nil;
    if (fileExists == NO)
    {
        tempDic = [NSMutableDictionary new];
    } else
    {
        tempDic = [self dataDictionary];
    }
    
    [tempDic setObject:data forKey:key];
    
    NSData *dicData = [NSKeyedArchiver archivedDataWithRootObject:tempDic];
    NSData *encryptedData = [self encryptData:dicData withKey:_mSecretKey];
    [encryptedData writeToFile:[self filePath] atomically:YES];
}
//===========================================================
- (void) clearData
{
	NSDictionary* tempDic = [NSMutableDictionary dictionary];
    
    
    NSData *dicData = [NSKeyedArchiver archivedDataWithRootObject:tempDic];
    NSData *encryptedData = [self encryptData:dicData withKey:_mSecretKey];
    [encryptedData writeToFile:[self filePath] atomically:YES];
}
//===========================================================
- (NSData*) encryptData:(NSData*)data withKey:(NSString*)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
	return [self makeCryptedVersionOfData:data withKeyData:[keyData bytes] ofLength:(int)[keyData length] decrypt:false];
}
//===========================================================
- (NSData*) decryptData:(NSData*)data withKey:(NSString*)key
{
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self makeCryptedVersionOfData:data withKeyData:[keyData bytes] ofLength:(int)[keyData length] decrypt:true];
}

//===========================================================
- (NSData*) dataForKey:(NSString*)key
{
    NSMutableDictionary *tempDic = [self dataDictionary];
    NSData *loadedData = [tempDic objectForKey:key];
    
    if (loadedData)
    {
        return loadedData;
    }
    
    return nil;
}
//===========================================================
- (void) saveObject:(id<NSCoding>)object key:(NSString*)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self saveData:data key:key];
}

//===========================================================
- (id) objectForKey:(NSString*)key
{
    NSData *data = [self dataForKey:key];
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}
//===========================================================
-(void) saveBool:(BOOL)boolean key:(NSString*)key
{
    NSNumber *number = [NSNumber numberWithBool:boolean];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:number];
    [self saveData:data key:key];
}
//===========================================================
-(BOOL) boolForKey:(NSString*)key
{
    NSData *data = [self dataForKey:key];
    if (data)
    {
		id unarchivedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
        return [unarchivedObj boolValue];
    }
    return NO;
}

#pragma mark - utils

//===========================================================
- (NSData*) makeCryptedVersionOfData:(NSData*)data withKeyData:(const void*)keyData ofLength:(int) keyLength decrypt:(bool)decrypt
{
	int keySize = kCCKeySizeAES256;
    char key[kCCKeySizeAES256];
	bzero(key, sizeof(key));
	memcpy(key, keyData, keyLength > keySize ? keySize : keyLength);
    
	size_t bufferSize = [data length] + kCCBlockSizeAES128;
	void* buffer = malloc(bufferSize);
    
	size_t dataUsed;
    
	CCCryptorStatus status = CCCrypt(decrypt ? kCCDecrypt : kCCEncrypt,
									 kCCAlgorithmAES128,
									 kCCOptionPKCS7Padding | kCCOptionECBMode,
									 key, keySize,
									 NULL,
									 [data bytes], [data length],
									 buffer, bufferSize,
									 &dataUsed);
				
	if(status != kCCSuccess)
	{
		WRErrorLog(@"WRGameKitHelper: Failed to encrypt!");
		
		free(buffer);
		return nil;
	}
    
	// NSData will take ownership of buffer and free itself
	return [NSData dataWithBytesNoCopy:buffer length:dataUsed];//EXIT
}

@end

#endif //!ANDROID
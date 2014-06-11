wrlib
=====

iOS utility library



This library is a collection of utilities that have often been helpful.  

Frameworks
---------------
* AdSupport
* CoreTelephony
* SystemConfiguration
* Gamekit - If using GameKitHelper
* CoreLocation - if using WRLocationManager

Required Third Party Lib
----------------------
* SSKeychain - https://github.com/samsoffes/sskeychain - Used by WRUUID
* AFNetworking - https://github.com/AFNetworking/AFNetworking - Uset by WRImageCache and other helpers


//-- Third party libs
// https://github.com/nicklockwood/OrderedDictionary
// https://github.com/samsoffes/sskeychain



Configuring Facebook Helper
------------------------
1. Add the facebook sdk.  Don't forget to:
	a. add the facebook id to plist
	b. add the FacebookDisplayName to plist
	c. add the fbNNNN urlhandler schemes to plist
2. integrate the facebook callbacks like they say in the docs in your app delegate
	a. handleAppDidFinishLaunchingWithOptions
	b. handleAppOpenURL
	c. handleAppDidBecomeActive
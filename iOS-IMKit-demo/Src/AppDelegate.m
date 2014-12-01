//
//  AppDelegate.m
//  iOS-IMKit-Demo
//
//  Created by Heq.Shinoda on 14-4-30.
//  Copyright (c) 2014年 iOS-IMKit-Demo. All rights reserved.
//

#import "AppDelegate.h"
#import "SigninViewController.h"
#import "DemoUIConstantDefine.h"
#import "DemoCommonConfig.h"
#import  <libNBSAppAgent/NBSAppAgent.h>
#import "HomeViewController.h"
#import "UserDataModel.h"

//使用DEMO注意：更换appkey，一定要更换对应的连接token，如果token未做变化，默认会从融云测试环境获取，照成appkey和token不一致
#define RONGCLOUD_IM_APPKEY    @"e0x9wycfx7flq"
//使用DEMO注意：更换appkey，一定要更换对应的连接token，如果token未做变化，默认会从融云测试环境获取，照成appkey和token不一致

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //注册听云
    [NBSAppAgent  startWithAppID:@"a546c342ba704acf91b27e9603b6860d"];
    NSString* appKey = [self readAppKeyFromConfig];
    [RCIM initWithAppKey:appKey deviceToken:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    
    [self defaultLogin];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    return YES;

    
}
-(void) defaultLogin
{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] length] != 0) {

        
        NSString *loginToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
        NSLog(@"loginToken is %@",loginToken);
        //使用DEMO注意：更换appkey，一定要更换对应的连接token，如果token未做变化，默认会从融云测试环境获取，照成appkey和token不一致
        [RCIM connectWithToken:loginToken completion:^(NSString *userId) {
            
            HomeViewController *temp = [[HomeViewController alloc]init];
            UINavigationController *rootNavi = [[UINavigationController alloc] initWithRootViewController:temp];
            [rootNavi.navigationBar setBarTintColor:[UIColor redColor]];
            //    [rootNavi.navigationBar setBackgroundImage:[self createImageWithColor:RGBCOLOR(43, 132, 210)] forBarMetrics:UIBarMetricsDefault];
            self.window.rootViewController = rootNavi;
            [self.window.rootViewController.view addSubview:temp.view];
            [self.window makeKeyAndVisible];
            
        } error:^(RCConnectErrorCode status) {
            
        }];
    }else{
        SigninViewController* loginVC = [[SigninViewController alloc] init];

        [loginVC.view setFrame:self.window.frame];
        UINavigationController *rootNavi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [rootNavi.navigationBar setBarTintColor:[UIColor redColor]];
        //    [rootNavi.navigationBar setBackgroundImage:[self createImageWithColor:RGBCOLOR(43, 132, 210)] forBarMetrics:UIBarMetricsDefault];
        self.window.rootViewController = rootNavi;
        [self.window.rootViewController.view addSubview:loginVC.view];
        [self.window makeKeyAndVisible];
    }
    
    
    


}
//#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
//#endif


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[RCIM sharedRCIM] getTotalUnreadCount];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DebugLog(@"error:%@",error);
    
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    DebugLog(@"RemoteNote userInfo:%@",userInfo);
    DebugLog(@" 收到推送消息： %@",userInfo[@"aps"][@"alert"]);
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

    DebugLog(@"deviceToken:%@",deviceToken);
    [[RCIM sharedRCIM]setDeviceToken:deviceToken];
}

-(UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

-(NSString*)readAppKeyFromConfig
{
//    return RONGCLOUD_IM_APPKEY;
    
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//[documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* appKey;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        appKey = RONGCLOUD_IM_APPKEY;//@"uwd1c0sxdlx91";
    else
        appKey = @"z3v5yqkbv8v30";//@"8luwapkvuxvel";
    return appKey;
}


@end

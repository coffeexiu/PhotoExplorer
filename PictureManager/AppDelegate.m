//
//  AppDelegate.m
//  PictureManager
//
//  Created by 蒋尚秀 on 15/12/18.
//  Copyright © 2015年 -JSX-. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import "BackgroundRunner.h"
#import "SeverListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    RootViewController * root = [[RootViewController alloc] init];
    
    SeverListViewController * sc = [[SeverListViewController alloc] init];
    
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:sc];
    
    self.window.rootViewController = nvc;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[BackgroundRunner shared] run];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[BackgroundRunner shared]stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

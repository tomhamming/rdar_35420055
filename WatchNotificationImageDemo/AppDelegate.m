//
//  AppDelegate.m
//  WatchNotificationImageDemo
//
//  Created by Hamming, Tom on 11/8/17.
//  Copyright © 2017 Olive Tree Bible Software. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error)
            NSLog(@"Error registering for notifications: %@", error);
    }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Test Title";
    content.body = @"There should be an image with this";
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"testCategory";
    
    NSDate *toSchedule = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitSecond value:10 toDate:[NSDate date] options:NSCalendarMatchNextTime];
    NSDateComponents *scheduleComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                                     fromDate:toSchedule];
    
    NSURL *bundledUrl = [[NSBundle mainBundle] URLForResource:@"05_18_NKJV" withExtension:@"jpg"];
    if (!bundledUrl)
        NSLog(@"Error: no image found!");
    
    NSArray *docDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [docDirectories firstObject];
    docsPath = [docsPath stringByAppendingPathComponent:bundledUrl.lastPathComponent];
    NSURL *docsUrl = [NSURL fileURLWithPath:docsPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:docsUrl.path])
    {
        NSError *copyErr = nil;
        [[NSFileManager defaultManager] copyItemAtURL:bundledUrl toURL:docsUrl error:&copyErr];
        if (copyErr)
            NSLog(@"Error copying file: %@", copyErr);
    }
    
    
    NSError *attachErr = nil;
    
    //Change the URL parameter here to use bundledUrl instead and the image may show up correctly
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"verse_image" URL:docsUrl options:nil error:&attachErr];
    if (attachErr)
        NSLog(@"Error attaching: %@", attachErr);
    else
        content.attachments = @[attachment];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:scheduleComp repeats:YES];
    NSString *identifier = @"ImageTest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
     {
         if (error)
         {
             NSLog(@"Error scheduling notification: %@", error);
         }
     }];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

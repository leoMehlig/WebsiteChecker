//
//  AppDelegate.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 17.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   
    // Insert code here to initialize your application
}
- (void)applicationWillResignActive:(NSNotification *)notification
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"save" object:self];
}
- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"save" object:self];
}

@end

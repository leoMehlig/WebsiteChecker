//
//  Refresher.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 21.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
@class URLFile, URLWithNextRefreshDateAndIntervalTime, DatePathsItems;

@interface Refresher : NSObject

@property (retain, nonatomic) URLFile* urlFile;

@property (retain, nonatomic) NSMutableArray* nextRefreshURLsArray;
@property (retain, nonatomic) NSTimer* timer;


- (void) setNextTimer;
- (void) refreshWithTimer:(NSTimer*) timer;
- (void) addWebsiteToRefreshTimer: (DatePathsItems*) website;
- (void) removeWebsiteFromRefreshTimer: (NSString*) url;
- (void) setLastRefreshDateForURL:(NSString*) url;
+(Refresher*) sharedRefresher;

@end

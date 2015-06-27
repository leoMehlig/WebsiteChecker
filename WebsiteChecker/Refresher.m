//
//  Refresher.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 21.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "Refresher.h"
#import "URLFile.h"
#import "URLWithNextRefreshDateAndIntervalTime.h"
#import "DatePathsItems.h"


static Refresher *_sharedRefresher = nil;

@implementation Refresher

- (NSTimer *)timer
{
    if (!_timer) _timer = [[NSTimer alloc]init];
    return _timer;
}
- (id)init
{
    if (_sharedRefresher) {
        NSLog(@"Second instance");
        exit(1);
    }
    self = [super init];
    if (self) {
        for (DatePathsItems* datePathItem in self.urlFile.datePaths) {
            [self addWebsiteToRefreshTimer:datePathItem];
        }
    }
    return self;
}

+(Refresher*) sharedRefresher {
    if (!_sharedRefresher) {
        _sharedRefresher = [[Refresher alloc] init];
    }
    return _sharedRefresher;
}

#pragma mark - Init

- (NSMutableArray *)nextRefreshURLsArray
{
    if (!_nextRefreshURLsArray) {
        _nextRefreshURLsArray = [[NSMutableArray alloc]init];
        
    }
    [_nextRefreshURLsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nextRefreshDate" ascending:YES]]];
    return _nextRefreshURLsArray;
}

- (URLFile *)urlFile
{
    if (!_urlFile) {
        _urlFile = [URLFile sharedURLFile];
        [_urlFile retain];
    }
    return _urlFile;
}

#pragma mark - Timer

- (void)addWebsiteToRefreshTimer:(DatePathsItems *)website
{
    if (website) {
            URLWithNextRefreshDateAndIntervalTime* urlWebsite =[[URLWithNextRefreshDateAndIntervalTime alloc]initWithURl:website.url refreshInterval:website.interval lastRefreshDate:[NSDate date]];
        [self.nextRefreshURLsArray addObject:urlWebsite];
        [urlWebsite release];
    }
    
}
- (void)removeWebsiteFromRefreshTimer:(NSString *)url
{
    for (URLWithNextRefreshDateAndIntervalTime* website in self.nextRefreshURLsArray) {
        if ([website.url isEqualToString:url])
        {
            [self.nextRefreshURLsArray removeObject:website];
            break;
        }
    }
    [self setNextTimer];
}
- (void)setNextTimer
{
     NSLog(@"%s",__PRETTY_FUNCTION__);
    if (self.timer.isValid)[self.timer invalidate];
    [self.nextRefreshURLsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"nextRefreshDate" ascending:YES]]];
    URLWithNextRefreshDateAndIntervalTime* nextRefreshWebsite = self.nextRefreshURLsArray.firstObject;
    if (nextRefreshWebsite.nextRefreshDate.timeIntervalSinceNow < 0)
    {
        [self refreshWithTimer:self.timer];
    }
    self.timer = [NSTimer timerWithTimeInterval:[nextRefreshWebsite.nextRefreshDate timeIntervalSinceNow] target:self selector:@selector(refreshWithTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Refresh

- (void)refreshWithTimer:(NSTimer *)timer
{
    [self.timer invalidate];
    for (URLWithNextRefreshDateAndIntervalTime* refreshWebsite in self.nextRefreshURLsArray) {
        if ([refreshWebsite.nextRefreshDate isEqualToDate:[refreshWebsite.nextRefreshDate earlierDate:[NSDate date]]])
        {
             refreshWebsite.lastRefreshDate = [NSDate date];
            refreshWebsite.nextRefreshDate = [NSDate dateWithTimeInterval:refreshWebsite.refreshInterval sinceDate:refreshWebsite.lastRefreshDate];
            [self.urlFile refreshURL:refreshWebsite.url];
            
            
        }
    }
    [self setNextTimer];
}

- (void)setLastRefreshDateForURL:(NSString *)url
{
    for (URLWithNextRefreshDateAndIntervalTime* website in self.nextRefreshURLsArray) {
        if ([website.url isEqualToString:url]) {
            website.lastRefreshDate = [NSDate date];
        }
    }
}

- (void)dealloc
{
    [_nextRefreshURLsArray release];
    [_urlFile release];
    [_timer release];
    
    [super dealloc];
}

@end

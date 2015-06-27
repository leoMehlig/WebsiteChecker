//
//  URLWithNextRefreshDateAndIntervalTime.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 21.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "URLWithNextRefreshDateAndIntervalTime.h"

@implementation URLWithNextRefreshDateAndIntervalTime

-(instancetype)initWithURl:(NSString *)url
           refreshInterval:(double)refreshInterval
           lastRefreshDate:(NSDate *)refreshDate
{
    self = [super init];
    if (self)
    {
       
        self.url = url;
        self.refreshInterval = refreshInterval;
        self.lastRefreshDate = refreshDate;
        self.nextRefreshDate = self.nextRefreshDate;
    }
    return self;
}

- (NSDate *)nextRefreshDate
{
    return [NSDate dateWithTimeInterval:self.refreshInterval sinceDate:self.lastRefreshDate];
}

- (void)dealloc
{
    [_url release];
    [_lastRefreshDate release];
    [_nextRefreshDate release];
   
    [super dealloc];
}
@end

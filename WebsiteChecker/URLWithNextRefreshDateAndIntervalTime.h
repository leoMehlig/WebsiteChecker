//
//  URLWithNextRefreshDateAndIntervalTime.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 21.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLWithNextRefreshDateAndIntervalTime : NSObject

@property (retain, nonatomic) NSString* url;
@property (assign, nonatomic) double refreshInterval;
@property (retain, nonatomic) NSDate* lastRefreshDate;
@property (retain, nonatomic) NSDate* nextRefreshDate;

- (instancetype) initWithURl:(NSString*) url refreshInterval: (double) refreshInterval lastRefreshDate: (NSDate*) refreshDate;
@end

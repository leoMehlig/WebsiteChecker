//
//  datePathsItems.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "DatePathsItems.h"
@interface NSObject () <NSCoding>
@end

@implementation DatePathsItems
- (instancetype)initWithURL:(NSString *)url path:(NSString *)path interval:(double)interval
{
    self = [super init];
    if (self) {
        [_url retain];
        [_path retain];
        self.url = url;
        self.path = path;
        self.interval = interval;
        self.percentNews = 0.0;
    }
    return self;
    
}

- (void)dealloc
{
    [_url release];
    [_path release];
    [super dealloc];
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeDouble:self.interval forKey:@"interval"];
    [aCoder encodeFloat:self.percentNews forKey:@"news"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.url = [coder decodeObjectForKey:@"url"];
        self.path = [coder decodeObjectForKey:@"path"];
        self.interval = [coder decodeDoubleForKey:@"interval"];
        self.percentNews = [coder decodeFloatForKey:@"news"];
    }
    return self;
}
@end

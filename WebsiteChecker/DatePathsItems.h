//
//  datePathsItems.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatePathsItems : NSObject
@property (retain, nonatomic) NSString* url;
@property (retain, nonatomic) NSString* path;
@property (assign) double interval;
@property (assign) float percentNews;
- (instancetype) initWithURL:(NSString*) url path:(NSString*)path interval:(double) interval;
@end

//
//  StringVergleicher.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringComparator : NSObject{
    NSLock* _lock;
    NSUInteger indexOfFirstString;
    NSUInteger indexOfSecondeString;
        }
@property (assign) NSUInteger percentProgress;
@property (assign) int numberOfSameRequiert;
@property (assign) int lengthForSameSearchInText;
@property (assign) int minLengthOfDifference;
@property (retain, nonatomic) NSString* firstString;
@property (retain, nonatomic) NSString* secondeString;
@property (assign) BOOL shouldStop;
- (NSArray*) differencesBetweenString:(NSString*) firstString andString:(NSString*) secondeString;

@end

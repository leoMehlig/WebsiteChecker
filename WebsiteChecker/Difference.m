//
//  Unterschied.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "Difference.h"

@implementation Difference
- (id)initWithFirstRange:(NSRange)firstRange andSecondeRange:(NSRange)secondeRange
{
    self = [super init];
    if (self) {
        _firstStringRange = firstRange;
        _secondeStringRange = secondeRange;
       
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}
@end

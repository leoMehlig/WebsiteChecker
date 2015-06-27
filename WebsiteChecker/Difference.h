//
//  Unterschied.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Difference : NSObject
{
    
}
@property (assign) NSRange firstStringRange;
@property (assign) NSRange secondeStringRange;

- (id) initWithFirstRange:(NSRange)firstRange  andSecondeRange: (NSRange)secondeRange;
@end

//
//  StringVergleicher.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 25.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "StringComparator.h"
#import "Difference.h"
#import "CodeViewController.h"
@interface StringComparator ()

@end


NSUInteger windowsSize = 0;
NSUInteger numberOfSameCharaktersInRow = 0;
@implementation StringComparator
- (id)init
{
    self = [super init];
    if (self) {
        if (!_lock) _lock = [[NSLock alloc] init];
        _firstString = [[NSString alloc]init];
        _secondeString = [[NSString alloc]init];
        _lengthForSameSearchInText = 0;
        _minLengthOfDifference = 0;
    }
    return self;
}
- (void)dealloc
{
    [_firstString release];
    [_secondeString release];
    [super dealloc];
}


- (NSArray *)differencesBetweenString:(NSString *)firstString andString:(NSString *)secondeString
{
    self.shouldStop = NO;
    indexOfFirstString = 0;
    indexOfSecondeString = 0;
    self.firstString = firstString;
    self.secondeString = secondeString;
    self.percentProgress = 0;
    if (!self.numberOfSameRequiert) self.numberOfSameRequiert = 0;
    
    NSMutableArray* arrayOfDifferences = [NSMutableArray array];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    while (indexOfFirstString < self.firstString.length && indexOfSecondeString < self.secondeString.length) {
        if (self.shouldStop == YES) return nil;
        if (indexOfFirstString / (self.firstString.length / 100) > self.percentProgress)
            {//  NSLog(@"%lu > %lu",indexOfFirstString , self.firstString.length );
                self.percentProgress++;
                [nc postNotificationName:@"updateProgressBar" object:nil];
                
            }
        
        if ([firstString characterAtIndex:indexOfFirstString] == [secondeString characterAtIndex:indexOfSecondeString])
        {
            indexOfFirstString++;
            indexOfSecondeString++;
        }
        else {
            windowsSize = 1;
            
            NSInteger differentCharacterSecondeStringStart = indexOfSecondeString;
            NSInteger differentCharacterFirstStringStart = indexOfFirstString;
            BOOL sameFounded = NO;
            while (sameFounded == NO && (indexOfFirstString+windowsSize < self.firstString.length || indexOfSecondeString+windowsSize < self.secondeString.length)) {
                if (self.shouldStop == YES) return nil;
                sameFounded = [self comparAllObjectInWindowWithEndObejcts];
                windowsSize++;
            }
            if (sameFounded == NO && (indexOfFirstString+windowsSize == self.firstString.length || indexOfSecondeString+windowsSize == self.secondeString.length)) {
                NSRange firstStringRange = NSMakeRange(differentCharacterFirstStringStart, self.firstString.length - differentCharacterFirstStringStart);
                NSRange secondeStringRange = NSMakeRange(differentCharacterSecondeStringStart, self.secondeString.length - differentCharacterSecondeStringStart);
                
                Difference* difference = [[Difference alloc]initWithFirstRange:firstStringRange andSecondeRange:secondeStringRange ];
                [arrayOfDifferences addObject:difference];
                [difference release];
                return arrayOfDifferences;
            }
            if (sameFounded == YES)
            {
            
                NSRange firstStringRange = NSMakeRange(differentCharacterFirstStringStart, indexOfFirstString - differentCharacterFirstStringStart);
                NSRange secondeStringRange = NSMakeRange(differentCharacterSecondeStringStart, indexOfSecondeString - differentCharacterSecondeStringStart);
                
                Difference* difference = [[Difference alloc]initWithFirstRange:firstStringRange andSecondeRange:secondeStringRange];
                [arrayOfDifferences addObject:difference];
                [difference release];
            indexOfFirstString = indexOfFirstString + numberOfSameCharaktersInRow;
            indexOfSecondeString = indexOfSecondeString + numberOfSameCharaktersInRow;
            }
        }
        
        
        
    }
    if (indexOfFirstString < self.firstString.length ) {
        NSRange firstStringRange = NSMakeRange(indexOfFirstString, self.firstString.length - indexOfFirstString );
        NSRange secondeStringRange = NSMakeRange(indexOfSecondeString, 0);
        
        Difference* difference = [[Difference alloc]initWithFirstRange:firstStringRange andSecondeRange:secondeStringRange ];
        [arrayOfDifferences addObject:difference];
        [difference release];
    } else if (indexOfSecondeString < self.secondeString.length ) {
        NSRange secondeStringRange = NSMakeRange(indexOfSecondeString, self.secondeString.length - indexOfSecondeString);
        NSRange firstStringRange = NSMakeRange(indexOfFirstString, 0);
        
        Difference* difference = [[Difference alloc]initWithFirstRange:firstStringRange  andSecondeRange:secondeStringRange];
        [arrayOfDifferences addObject:difference];
        [difference release];
    }
    if (self.lengthForSameSearchInText != 0 || self.minLengthOfDifference != 0) {
        NSMutableArray* diffrencesToRemove = [NSMutableArray array];
        for ( Difference* difference in arrayOfDifferences) {
            BOOL checkSecondeCondition = YES;
            if (self.minLengthOfDifference != 0) {
                if (difference.firstStringRange.length < self.minLengthOfDifference && difference.secondeStringRange.length < self.minLengthOfDifference){
                    [diffrencesToRemove addObject:difference];
                    checkSecondeCondition = NO;
                }
            }
            if (checkSecondeCondition == YES && difference.secondeStringRange.length > self.lengthForSameSearchInText) {
                if (self.secondeString.length > difference.secondeStringRange.location + difference.secondeStringRange.length){
                    if ([self.firstString rangeOfString:[self.secondeString substringWithRange:difference.secondeStringRange]].location != NSNotFound ) {
                        [diffrencesToRemove addObject:difference];
                    }
                }
                if (self.firstString.length > difference.firstStringRange.location + difference.firstStringRange.length){
                    if ([self.secondeString rangeOfString:[self.firstString substringWithRange:difference.firstStringRange]].location != NSNotFound ) {
                        [diffrencesToRemove addObject:difference];
                    }
                }
            }
        }
        [arrayOfDifferences removeObjectsInArray:diffrencesToRemove];
    }
    self.percentProgress = 100;
    [nc postNotificationName:@"updateProgressBar" object:nil];

    return arrayOfDifferences;
}




- (NSInteger) numberOfSameCharectersForFirstIndex: (NSInteger) firstIndex andSecondeIndex: (NSInteger) secondeIndex
{
    NSInteger numberOfSameCharacters = 0;
    while (secondeIndex+numberOfSameCharacters+1 < self.secondeString.length && firstIndex+numberOfSameCharacters+1 < self.firstString.length) {
        if ([self.firstString characterAtIndex:firstIndex+numberOfSameCharacters+1] == [self.secondeString characterAtIndex:secondeIndex+numberOfSameCharacters+1]) {
            numberOfSameCharacters++;
        } else {
            return numberOfSameCharacters;
        }
    }
    return numberOfSameCharacters;
}

- (BOOL) comparAllObjectInWindowWithEndObejcts
{
    NSUInteger endIndexFirstString = indexOfFirstString+windowsSize;
    NSUInteger endIndexSecondeString = indexOfSecondeString+windowsSize;
    NSUInteger currentIndexFirstString = indexOfFirstString;
    NSUInteger currentIndxSecondeString = indexOfSecondeString;
    
    
    
    while (currentIndexFirstString < endIndexFirstString && currentIndxSecondeString < endIndexSecondeString) {
        if (self.shouldStop == YES) return NO;
        if (endIndexSecondeString < self.secondeString.length && currentIndexFirstString < self.firstString.length) {
            if ([self.firstString characterAtIndex:currentIndexFirstString] == [self.secondeString characterAtIndex:endIndexSecondeString]) {
                numberOfSameCharaktersInRow = [self numberOfSameCharectersForFirstIndex:currentIndexFirstString andSecondeIndex:endIndexSecondeString];
                if (numberOfSameCharaktersInRow >= self.numberOfSameRequiert) {
                    indexOfFirstString = currentIndexFirstString;
                    indexOfSecondeString = endIndexSecondeString;
                    return YES;
                }
            }
        }
            if (currentIndxSecondeString < self.secondeString.length && endIndexFirstString < self.firstString.length) {
                if ([self.firstString characterAtIndex:endIndexFirstString] == [self.secondeString characterAtIndex:currentIndxSecondeString]) {
                    numberOfSameCharaktersInRow = [self numberOfSameCharectersForFirstIndex:endIndexFirstString andSecondeIndex:currentIndxSecondeString];
                    if (numberOfSameCharaktersInRow >= self.numberOfSameRequiert) {
                        indexOfSecondeString = currentIndxSecondeString;
                        indexOfFirstString = endIndexFirstString;
                        return YES;
                    }
                }
            }
            
            currentIndexFirstString++;
            currentIndxSecondeString++;
        
    }
        if (currentIndexFirstString < self.firstString.length && currentIndxSecondeString < self.secondeString.length) {
            if ([self.firstString characterAtIndex:currentIndexFirstString] == [self.secondeString characterAtIndex:currentIndxSecondeString]) {
                numberOfSameCharaktersInRow = [self numberOfSameCharectersForFirstIndex:currentIndexFirstString andSecondeIndex:currentIndxSecondeString];
                if (numberOfSameCharaktersInRow >= self.numberOfSameRequiert) {
                    indexOfFirstString = currentIndexFirstString;
                    indexOfSecondeString = currentIndxSecondeString;
                    return YES;
                }
            }
        }
    
    
    return NO;
}

@end

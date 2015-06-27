//
//  CodeFile.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "CodeFile.h"
#import "DateFile.h"
#import "URLFile.h"

@implementation CodeFile
#pragma mark - Init
- (NSString *)code
{
    if (!_code) _code = [[NSString alloc]init];
    return _code;
}
- (NSString *)uniqueID
{
    if (!_uniqueID) _uniqueID = [[NSString alloc]init];
    return _uniqueID;
}
- (URLFile *)urlFile
{
    if (!_urlFile){
        _urlFile = [URLFile sharedURLFile];
        [_urlFile retain];
    }
    return _urlFile;
}

- (DateFile *)dateFile
{
    if (!_dateFile) _dateFile = [[DateFile alloc]init];
    return _dateFile;
}

#pragma mark - Add

- (NSString *)creatCode:(NSString *)code
{
    NSString* uniqueID = [self.urlFile uniqueID];
    [self saveCode:code withUniqueID:uniqueID];
    return uniqueID;
}

- (NSString *)codeForPath:(NSString *)path
{
    self.uniqueID = path;
    self.code = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.urlFile dataFilePathWithPathComponent:path]];
    if (self.code) return self.code;
    return nil;
}

#pragma mark - Save/Load

- (void) saveCode: (NSString*) code withUniqueID: (NSString*) uniqueID
{
    self.code = code;
    self.uniqueID = uniqueID;
    if (![NSKeyedArchiver archiveRootObject:self.code toFile:[self.urlFile dataFilePathWithPathComponent:self.uniqueID]]) NSLog(@"DatePaths archiving failed");
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.code forKey:self.uniqueID];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.code = nil;
        self.code = [aDecoder decodeObjectForKey:self.uniqueID];
    }
    return self;
}


- (void)dealloc
{
    [_uniqueID release];
    [_code release];
    [_dateFile release];
    [_urlFile release];
    [super dealloc];
}
@end

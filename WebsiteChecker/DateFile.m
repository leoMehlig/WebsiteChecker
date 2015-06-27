//
//  DateFile.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "DateFile.h"
#import "URLFile.h"
#import "CodeFile.h"
#import "DatePathsItems.h"
#import "StringComparator.h"
#import "Difference.h"
@interface DateFile () <NSCoding>
@property (retain, nonatomic) NSString* uniqueID;
@property (retain, nonatomic) NSMutableArray* codePathArray;
@end
@implementation DateFile
@synthesize uniqueID = _uniqueID;
#pragma mark - Init
- (URLFile *)urlFile
{
    if (!_urlFile) {
        _urlFile = [URLFile sharedURLFile];
        [_urlFile retain];
    }
    return _urlFile;
}

- (CodeFile *)codeFile
{
    if (!_codeFile) _codeFile = [[CodeFile alloc]init];
    return _codeFile;
}
- (NSString *)uniqueID
{
    if (!_uniqueID) _uniqueID = [[NSString alloc]init];
    return _uniqueID;
}
-(NSMutableArray *)codePathArray
{
    if (!_codePathArray) _codePathArray = [[NSMutableArray alloc]init];
    return _codePathArray;
}
- (void) setUniqueID:(NSString *)uniqueID
{
    _uniqueID = uniqueID;
}
#pragma mark - Variablen

- (NSMutableArray *)datesForPath:(NSString *)path
{
    self.uniqueID = path;
    self.codePathArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.urlFile dataFilePathWithPathComponent:path]];
    if (self.codePathArray){
        return self.codePathArray;
    }
    NSLog(@"Failed loading dates for Path: %@", path);
    return nil;
}

- (NSString *)codeForDate:(NSDate *)date inPath:(NSString *)path
{
    self.uniqueID = path;
    NSString* codePath = [self codePathForDate:date];
    if (codePath)
    {
        NSString* code = [self.codeFile codeForPath:codePath];
        if (code) return code;
        else NSLog(@"Code for Date:%@ inPath:%@", date, path);
    }
    else NSLog(@"CodePath for Date: %@ not found", date);
    return nil;
    
}
- (NSString*) codePathForDate: (NSDate*) date
{
    self.codePathArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.urlFile dataFilePathWithPathComponent:self.uniqueID]];
    
    for (NSDictionary* dateAndPathDict in self.codePathArray) {
        if ([dateAndPathDict[DATEKEY] isEqualToDate:date]) {
            return dateAndPathDict[CODEPATHKEY];
        }
    }
    NSLog(@"CodePath for Date: %@ not found", date);
    return nil;
}

#pragma mark - Add/Remove

- (NSString *)creatArrayWithDate:(NSDate *)date withCode:(NSString *)code
{
    self.uniqueID = [self.urlFile uniqueID];
    NSMutableArray* dateArray = [NSMutableArray arrayWithObject:@{DATEKEY: date, CODEPATHKEY: [self.codeFile creatCode:code]}];
    [self saveRootArray:dateArray withUniqueID:self.uniqueID];
    return self.uniqueID;
}

- (BOOL)addDate:(NSDate *)date withCode:(NSString *)code toDatePath:(NSString *)path
{
     NSLog(@"%s",__PRETTY_FUNCTION__);
    self.uniqueID = path;
    self.codePathArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.urlFile dataFilePathWithPathComponent:path]];
    if (!self.codePathArray){
        NSLog(@"DecodeDateArrayFailed");
        return NO;
    }
    
    NSString* latestCode = [self.codeFile codeForPath:self.codePathArray.lastObject[CODEPATHKEY]];
    if (![code isEqualToString:latestCode])
  
    {
        dispatch_queue_t myQueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myQueue, ^{
            [self.urlFile.accessLock lock];

            StringComparator* stringVergleicher = [[StringComparator alloc]init];
            stringVergleicher.numberOfSameRequiert = 100;
            stringVergleicher.lengthForSameSearchInText = 100;
            stringVergleicher.minLengthOfDifference = 20;
            NSArray* differences  = [stringVergleicher differencesBetweenString:[self.codeFile codeForPath:self.codePathArray.firstObject[CODEPATHKEY]] andString:code];
            [stringVergleicher release];
            [self.urlFile.accessLock unlock];
            NSUInteger numberOfDifferentCharacter = 0;
            
            for (Difference* difference in differences) numberOfDifferentCharacter = numberOfDifferentCharacter + difference.secondeStringRange.length;
            
            float percent = numberOfDifferentCharacter / (code.length / 100);
            
            
            
            for (DatePathsItems* datePathItem in self.urlFile.datePaths) {
                if ([datePathItem.path isEqualToString:path]) {
                    datePathItem.percentNews = percent;
                    [self.urlFile saveDatePaths];
                    break;
                }
            }
            [self.codePathArray addObject:@{DATEKEY: date, CODEPATHKEY:[self.codeFile creatCode:code]}];
            [self saveRootArray:self.codePathArray withUniqueID:self.uniqueID];
            

            
        });
        
        
      
    } else {
        [self.codePathArray replaceObjectAtIndex:self.codePathArray.count - 1 withObject:@{DATEKEY: [NSDate date], CODEPATHKEY: self.codePathArray.lastObject[CODEPATHKEY]}];
  
    }
    
    return YES;
    
}
- (void) reloadData
{
     NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"reloadData" object:nil];
}
- (void)removeCodeForURL:(NSString *)url
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    
    for (NSDictionary* dict in [self datesForPath:[self.urlFile datePathForURL:url]]) {
        error = nil;
        [fileManager removeItemAtPath:[self.urlFile dataFilePathWithPathComponent:dict[CODEPATHKEY]] error:&error];
        if (error) {
            NSLog(@"Delet Url: %@, Error: %@", url, error);
        }
    }
    
}




#pragma mark - Save/Load

- (void) saveRootArray: (NSMutableArray*) rootArray withUniqueID: (NSString*) uniqueID
{
    self.codePathArray = rootArray;
    self.uniqueID = uniqueID;
    if (![NSKeyedArchiver archiveRootObject:self.codePathArray toFile:[self.urlFile dataFilePathWithPathComponent:self.uniqueID]]) NSLog(@"DatePaths archiving failed");
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.codePathArray forKey:self.uniqueID];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.codePathArray = nil;
        self.codePathArray = [aDecoder decodeObjectForKey:self.uniqueID];
    }
    return self;
}
- (void)dealloc
{

    [_uniqueID release];
    [_codePathArray release];
    [_urlFile release];
    [_codeFile release];
   
    [super dealloc];
}

@end

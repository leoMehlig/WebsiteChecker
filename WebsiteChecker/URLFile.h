//
//  URLFile.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
#define URLKEY @"urlKey" 
#define DATEPATHKEY @"datePathKey"
#define REFRESHINTERVAL @"timerKey"
#define NEXTREFRESHDATE @"nextRefreshDate"

@class DateFile, Refresher;
@interface URLFile : NSObject  <NSCoding, NSURLConnectionDataDelegate> {
    NSLock*_addUrlLock;
    
}
@property (retain, nonatomic) DateFile* dateFile;
@property (retain, nonatomic) Refresher* refresher;
@property (retain, nonatomic) NSMutableArray* threadArray;
@property (retain, nonatomic) NSMutableArray* datePaths;
@property (retain, nonatomic) NSMutableArray* urls;
@property (nonatomic, retain) NSLock *accessLock;
@property (nonatomic, retain) NSMutableDictionary* loadingURLs;
- (NSMutableArray*) datesForURLString:(NSString*) url;
- (NSString*) codeForURL: (NSString*) url forDate: (NSDate*)date;
- (NSString*) datePathForURL:(NSString*)url;

- (NSString*) dataFilePathWithPathComponent:(NSString*)pathComponent;
- (NSString*) uniqueID;

- (void) removeURL:(NSString*) url;
- (BOOL) addURL:(NSString*) url withRefreshInterval:(double) intervalInSeconds withCode: (NSString*) code;



- (BOOL) refreshURL:(NSString*)url;
- (NSString*) codeForURL:(NSString*) url;
- (void) saveDatePaths;
- (void) reloadDatePaths;
+(instancetype) sharedURLFile;

@end

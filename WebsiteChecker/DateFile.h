//
//  DateFile.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DATEKEY @"dateKey"
#define CODEPATHKEY @"codePathKey"
@class URLFile, CodeFile;

@interface DateFile : NSObject

@property (retain, nonatomic) URLFile* urlFile;
@property (retain, nonatomic) CodeFile* codeFile;

- (NSString*) codeForDate: (NSDate*) date inPath:(NSString*)path;
- (NSMutableArray*) datesForPath:(NSString*)path;

- (BOOL) addDate:(NSDate*)date withCode:(NSString*) code toDatePath:(NSString*)path;
- (NSString*) creatArrayWithDate:(NSDate*)date withCode:(NSString*)code;

- (void) removeCodeForURL:(NSString*) url;
@end

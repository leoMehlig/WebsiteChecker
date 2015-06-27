//
//  CodeFile.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DateFile;
@class URLFile;
@interface CodeFile : NSObject <NSCoding>

@property (retain, nonatomic) DateFile* dateFile;
@property (retain, nonatomic) URLFile* urlFile;

@property (retain, nonatomic) NSString* code;
@property (retain, nonatomic) NSString* uniqueID;

- (NSString *)creatCode:(NSString *)code;
- (NSString*) codeForPath:(NSString*)path;
@end

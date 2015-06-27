//
//  DatumsViewController.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 17.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
@class URLFile, CodeFile, DateFile, CodeViewController;

@interface DatumsViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (assign, nonatomic) IBOutlet NSTableView *tableView;

@property (assign) IBOutlet CodeViewController *codeVC;

@property (retain, nonatomic) URLFile* urlFile;
@property (retain, nonatomic) CodeFile* codeFile;
@property (retain, nonatomic) DateFile* dateFile;

- (void) didSelectURLString:(NSString*)urlString;

@end

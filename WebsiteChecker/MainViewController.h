//
//  MainViewController.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 17.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#define URLDEF @"url"
#define DATUM @"date"
#define CODE @"code"
#define DETAILS @"details"
@class URLFile, CodeFile, DateFile, Refresher, DatumsViewController;

@interface MainViewController : NSObject  <NSTableViewDataSource, NSTableViewDelegate>

@property (assign, nonatomic) IBOutlet NSTableView *tableView;

@property (assign) IBOutlet DatumsViewController *datumsVC;

@property (retain, nonatomic) URLFile* urlFile;
@property (retain, nonatomic) CodeFile* codeFile;
@property (retain, nonatomic) DateFile* dateFile;
@property (retain, nonatomic)  Refresher *refresher;

@end

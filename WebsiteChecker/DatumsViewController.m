//
//  DatumsViewController.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 17.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "DatumsViewController.h"
#import "URLFile.h"
#import "DateFile.h"
#import "CodeFile.h"
#import "CodeViewController.h"
@interface DatumsViewController ()

@property (retain) NSMutableArray* datesArray;
@property (retain) NSString* currentURLString;
@property (retain, nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation DatumsViewController
#pragma mark - Init

- (void)dealloc
{
    
    [_urlFile release];
    [_dateFile release];
    [_codeFile release];
    [_datesArray release];
    [_currentURLString release];
    [_dateFormatter release];
    [super dealloc];
}

- (DateFile *)dateFile
{
    if (!_dateFile) _dateFile = [[DateFile alloc]init];
    return _dateFile;
}

- (URLFile *)urlFile
{
    if (!_urlFile){
        _urlFile = [[URLFile alloc]init];
        [_urlFile retain];
    }
    return _urlFile;
}

- (CodeFile *)codeFile
{
    if (!_codeFile) _codeFile = [[CodeFile alloc]init];
    return _codeFile;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}


#pragma mark - Reload Data/Table View

- (void)didSelectURLString:(NSString *)urlString
{
    self.datesArray = [self.urlFile datesForURLString:urlString];
    self.currentURLString = urlString;
    
    [self.tableView reloadData];
    if (self.tableView.selectedRow == -1) [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.datesArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.dateFormatter stringFromDate:self.datesArray[row]];
}


#pragma mark - Selected


- (IBAction)pushVergleichButton:(NSButton *)sender {
    if (self.tableView.selectedRowIndexes.count != 2) return;
    [self refreshContentView];
    
}

- (void) refreshContentView
{
    if (self.tableView.selectedRowIndexes.count != 2) return;
    [self.codeVC didSelectDate:self.datesArray[self.tableView.selectedRowIndexes.firstIndex] forURL:self.currentURLString withComparDate:self.datesArray[self.tableView.selectedRowIndexes.lastIndex]];
}

@end


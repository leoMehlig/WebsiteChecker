//
//  MainViewController.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 17.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "MainViewController.h"
#import "DatumsViewController.h"
#import "URLFile.h"
#import "DateFile.h"
#import "CodeFile.h"
#import "Refresher.h"
#import "DatePathsItems.h"
@interface MainViewController () <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableData* _dataFromNewURLWebsite;
    double refreshInterval;
}

@property (assign) IBOutlet NSButton *refreshButton;

@end

@implementation MainViewController


- (id)init
{
    self = [super init];
    if (self) {
        [self refreshAll];
    }
    return self;
}


-(void)awakeFromNib
{
    [self reloadDataForTableView];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(refreshDateTabelView) name:@"updateUI" object:nil];
    [nc addObserver:self selector:@selector(reloadDataForTableView) name:@"reloadData" object:nil];
    
    
}

- (void)dealloc
{
    [_urlFile release];
    [_dateFile release];
    [_codeFile release];
    [_refresher release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) reloadDataForTableView
{
    [self.urlFile reloadDatePaths];
    [self.tableView reloadData];
}



#pragma mark - Init

- (DateFile *)dateFile
{
    if (!_dateFile) _dateFile = [[DateFile alloc]init];
    return _dateFile;
}


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
- (Refresher *)refresher
{
    if (!_refresher) {
        _refresher = [Refresher sharedRefresher];
    }
    return _refresher;
}
#pragma mark - Editing

#pragma mark Add

- (IBAction)pushAdd:(id)sender
{
    //Hier wird ein AlertView erstellt in dem man die URL und die RefreshInterval eingeben kann. (Hier sollte besser ein Sheet hin).
    NSAlert *alert = [NSAlert alertWithMessageText: @"Neue URL hinzufügen"
                                     defaultButton:@"Hinzufügen"
                                   alternateButton:@"Abbrechen"
                                       otherButton:nil
                         informativeTextWithFormat:@"Gebe die URL der Website und den Aktualiesierungs-Interval ein"];
    
    NSView* accessoryViewForAlert = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 300, 24)];
    //TextFiled für die URL eingabe wird erstellt.
    NSTextField *urlTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 170, 24)];
    urlTextField.stringValue = @"Website-URL";
    
    //Der PopUpButton zum auswählen des Refresh-Intervals wird erstellt.
    NSPopUpButton* popUpButton = [[NSPopUpButton alloc]initWithFrame:NSMakeRect(200, 0, 100, 24) pullsDown:NO];
    NSDictionary* refreshIntervalsForPopUp =  @{@"30 sek.": @30, @"1 min.": @60, @"2 min.": @120, @"5 min.": @300, @"10 min.": @600, @"30 min.": @1800, @"1 Std.": @3600};
    
    [popUpButton addItemsWithTitles:[refreshIntervalsForPopUp keysSortedByValueUsingSelector:@selector(compare:)]];
    popUpButton.title = @"10 min.";
    
    [accessoryViewForAlert addSubview:urlTextField];
    [accessoryViewForAlert addSubview:popUpButton];
    
    [alert setAccessoryView:accessoryViewForAlert];
    NSInteger numberOfAlertButton = [alert runModal];
    [accessoryViewForAlert release];
    
    //Wird überpfrüft ob Abbrechen gedrückt wurde.
    if (numberOfAlertButton == 0) {
        [urlTextField release];
        [popUpButton release];
        return;
    }
    
    //Die URL wird angepasst
    NSString* urlString = urlTextField.stringValue;
    [urlTextField release];
    if (![urlString hasPrefix:@"http://"]) {
        if (![urlString hasPrefix:@"www."]) urlString = [NSString stringWithFormat:@"http://www.%@", urlString];
        else urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    
    //Interval zuweisen
    refreshInterval = [refreshIntervalsForPopUp[popUpButton.titleOfSelectedItem] doubleValue];
    [popUpButton release];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection* connencetion = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    [connencetion start];
    
}

#pragma mark Network

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSAlert * encodingFailedAlert = [NSAlert alertWithError:error];
    [encodingFailedAlert runModal];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_dataFromNewURLWebsite) _dataFromNewURLWebsite = [[NSMutableData alloc]initWithData:data];
    else [_dataFromNewURLWebsite appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_dataFromNewURLWebsite) {
        //Eine neue URL mit Date wird angelegt.
        NSString* HTMLCodeString = [[NSString alloc]initWithData:_dataFromNewURLWebsite encoding:NSUTF8StringEncoding];
        if (!HTMLCodeString) HTMLCodeString = [[NSString alloc]initWithData:_dataFromNewURLWebsite encoding:NSASCIIStringEncoding];
        if (!HTMLCodeString) {
            NSAlert * encodingFailedAlert = [NSAlert alertWithMessageText:@"HTML-Encoding fehlgeschlagen" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Leider lässt sich Website nicht encoden."];
            encodingFailedAlert.alertStyle = NSWarningAlertStyle;
            [encodingFailedAlert runModal];
            return;
        }
        [self.urlFile addURL:connection.currentRequest.URL.absoluteString  withRefreshInterval:refreshInterval withCode:HTMLCodeString];
        
        //Die TableView wird neu geladen und die neue URL wird ausgewählt.
        [self.tableView reloadData];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.numberOfRows-1] byExtendingSelection:NO];
        [self refreshDateTabelView];
        
        
    }
}


#pragma mark Remove


- (IBAction)pushRemove:(id)sender
{
    //Alle Daten der URL werden entfernt und die URL wird auch aus dem Timer entfernt
    [self.refresher removeWebsiteFromRefreshTimer:self.urlFile.urls[self.tableView.selectedRow]];
    [self.urlFile removeURL:self.urlFile.urls[self.tableView.selectedRow]];
    
    //Wenn keine Celle selektiert ist wird die unterste ausgewählt.
    [self.tableView reloadData];
    if (self.tableView.selectedRow == -1) [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.numberOfRows-1] byExtendingSelection:NO];
    [self refreshDateTabelView];
}



#pragma mark- Refresh

- (IBAction)pushRefresh:(NSButton *)sender {
    
    [self refreshAll];
}

- (void) refreshAll
{
    [self.refresher.timer invalidate];
    if (!self.urlFile.urls.count) return;
    for (DatePathsItems* dateParthItem in self.urlFile.datePaths) {
        [self.urlFile refreshURL:dateParthItem.url];
        [self.refresher setLastRefreshDateForURL:dateParthItem.url];
        
    }
    [self.refresher setNextTimer];
}



#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.urlFile.datePaths.count;
}



- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    if (self.urlFile.datePaths.count == 0) return nil;
    DatePathsItems* currentDatePath = self.urlFile.datePaths[row];
    if ([tableColumn.identifier isEqualToString:@"url"]){
        return currentDatePath.url;
    }
    else {
        return [NSString stringWithFormat:@"%.1f%%", currentDatePath.percentNews];
        
    }
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self refreshDateTabelView];
}



- (void) refreshDateTabelView
{
    if (self.tableView.selectedRow == -1 || self.urlFile.datePaths.count == 0) return;
    
    DatePathsItems* currentDatePathItem = self.urlFile.datePaths[self.tableView.selectedRow];
    [self.datumsVC didSelectURLString:currentDatePathItem.url];
}




@end

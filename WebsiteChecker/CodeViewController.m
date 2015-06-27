//
//  CodeViewController.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 20.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "CodeViewController.h"
#import "URLFile.h"
#import "StringComparator.h"
#import "Difference.h"
#import "Refresher.h"
@interface CodeViewController ()
@property (retain, nonatomic) StringComparator* stringComparator;
@end
@implementation CodeViewController
#pragma mark - Init


- (void)awakeFromNib
{
    [self.shouldLoadResourcesCheckBox addObserver:self forKeyPath:@"cell.state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.tabViewItemCode addObserver:self forKeyPath:@"tabState" options:NSKeyValueObservingOptionNew context:NULL];
    [self.tabViewItemWeb addObserver:self forKeyPath:@"tabState" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (void)dealloc
{
    [_shouldLoadResourcesCheckBox removeObserver:self forKeyPath:@"cell.state"];
    [_tabViewItemCode removeObserver:self forKeyPath:@"tabState"];
    [_tabViewItemWeb removeObserver:self forKeyPath:@"tabState"];
    
    [_urlFile release];
    [_firstHTMLCodeString release];
    [_secondeHTMLCodeString release];
    [_URLStringForCode release];
    [_differencesFromStringsArray release];
    [_stringComparator release];
    [super dealloc];
}


- (URLFile *)urlFile
{
    if (!_urlFile) {
        _urlFile = [URLFile sharedURLFile];
        [_urlFile retain];
    }
    return _urlFile;
}


- (NSString *)firstHTMLCodeString
{
    if (!_firstHTMLCodeString) _firstHTMLCodeString = [[NSString alloc]init];
    return _firstHTMLCodeString;
}

-(NSString *)URLStringForCode
{
    if (!_URLStringForCode) _URLStringForCode = [[NSString alloc]init];
    return _URLStringForCode;
}

- (NSString *)secondeHTMLCodeString
{
    if (!_secondeHTMLCodeString) _secondeHTMLCodeString = [[NSString alloc]init];
    return _secondeHTMLCodeString;
}

- (NSMutableArray *)differencesFromStringsArray
{
    if (!_differencesFromStringsArray) _differencesFromStringsArray = [[NSMutableArray alloc]init];
    return _differencesFromStringsArray;
}


-(StringComparator *)stringComparator
{
    if (!_stringComparator)  _stringComparator = [[StringComparator alloc]init];
   return  _stringComparator;
}


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"cell.state"]) {
        if (self.tabViewItemWeb.tabState == NSSelectedTab)
        {
            [self loadWebView];
            
        }
    }
    
    else if ([keyPath isEqualToString:@"tabState"]) {
        
        if (object == self.tabViewItemCode) [self startStringComparator];
        else if (object == self.tabViewItemWeb) [self loadWebView];
        else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark - Reload Data


- (void)didSelectDate:(NSDate *)date forURL:(NSString *)url withComparDate:(NSDate *)comparDate
{
    self.URLStringForCode = url;
    self.firstHTMLCodeString = [self.urlFile codeForURL:url forDate:date];
    self.secondeHTMLCodeString = [self.urlFile codeForURL:url forDate:comparDate];
   
    
    if (self.tabViewItemCode.tabState == NSSelectedTab) {
        
        [self startStringComparator];
    }
    
    else if (self.tabViewItemWeb.tabState == NSSelectedTab) [self loadWebView];
    
}

#pragma mark _ Progress Bar


- (void)updateComparStringProgressBar
{
   
    if (_stringComparator) {
        //Die Progress Bar wird um ein Prozent erhöht.
        NSUInteger increment = self.stringComparator.percentProgress - self.comparStringProgressBar.doubleValue;
        
    if (increment > 0)[self.comparStringProgressBar incrementBy:self.stringComparator.percentProgress - self.comparStringProgressBar.doubleValue];
    }
    // Wenn sie voll ist wird sie entfernt.
    if (self.comparStringProgressBar.doubleValue >= 100 || self.stringComparator.percentProgress >= 100)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateProgressBar" object:nil];
        [self.comparStringProgressBar setIndeterminate:NO];
        [self.comparStringProgressBar stopAnimation:self];
        
        
    }
}

#pragma mark - Comparison


- (void) startStringComparator
{
    
    [self.comparStringProgressBar setHidden:NO];
    [self.comparStringProgressBar startAnimation:self];
    
    Refresher* refresher = [Refresher sharedRefresher];
    [refresher.timer invalidate];
    
    self.stringComparator.shouldStop = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComparStringProgressBar) name:@"updateProgressBar" object:nil];
    
    dispatch_queue_t codeViewComparisonQueue = dispatch_queue_create("CodeViewComparisonQueue", NULL);
    dispatch_async(codeViewComparisonQueue, ^{
        
        [self.urlFile.accessLock lock];
        
        self.stringComparator.numberOfSameRequiert = 100;
        self.stringComparator.lengthForSameSearchInText = 100;
        self.stringComparator.minLengthOfDifference = 20;
        
        self.differencesFromStringsArray = [NSMutableArray arrayWithArray:[self.stringComparator differencesBetweenString:self.firstHTMLCodeString andString:self.secondeHTMLCodeString]];
        if (self.differencesFromStringsArray == nil){
            [self.urlFile.accessLock unlock];
            return;
        }
        
        Refresher* refresher = [Refresher sharedRefresher];
        [refresher refreshWithTimer:nil];
        
        [self.urlFile.accessLock unlock];
        
        [self performSelectorOnMainThread:@selector(loadCodeView) withObject:nil waitUntilDone:NO];
        

        
    });
    

    }


#pragma mark - Code/Web


- (void) loadCodeView
{
    //spätestens jetzt wird die Progress Bar entfernt.
    if ([self.comparStringProgressBar isIndeterminate]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateProgressBar" object:nil];
        [self.comparStringProgressBar setIndeterminate:NO];
        [self.comparStringProgressBar stopAnimation:self];
        [self.comparStringProgressBar setHidden:YES];
    }
    
    self.firstHTMLCodeView.string = self.firstHTMLCodeString;
    self.secondeHTMLCodeView.string = self.secondeHTMLCodeString;

    if (!self.differencesFromStringsArray) return;

    NSUInteger numberOfDifferentCharacter = 0;
    
    for (Difference* difference in self.differencesFromStringsArray) {
        
        //Die Nummer der unterschiedlichen Zeichen wird angepasst.
        numberOfDifferentCharacter = numberOfDifferentCharacter + difference.secondeStringRange.length;
        
        //Die Unterschied werden Geld hinterlegt und Fett gemacht.
       [self.secondeHTMLCodeView.textStorage addAttributes:@{ NSBackgroundColorAttributeName: [NSColor yellowColor], NSFontAttributeName: [NSFont boldSystemFontOfSize:self.firstHTMLCodeView.textStorage.font.pointSize]} range:difference.secondeStringRange];
        
        [self.firstHTMLCodeView.textStorage addAttributes:@{ NSBackgroundColorAttributeName: [NSColor yellowColor], NSFontAttributeName: [NSFont boldSystemFontOfSize:self.firstHTMLCodeView.textStorage.font.pointSize]} range:difference.firstStringRange];
    }
    
    NSLog(@"diffentCharakters: %lu, length: %lu Prozent%lu",numberOfDifferentCharacter, self.secondeHTMLCodeString.length, numberOfDifferentCharacter / (self.secondeHTMLCodeString.length / 100));
    
}

- (void) loadWebView
{
    
    if (self.shouldLoadResourcesCheckBox.state == NSOnState){
        //Läd Resourcen mit weil kein Delegat gesetzt wurde.
        [self.firstWebView setResourceLoadDelegate:nil];
        [self.secondeWebView setResourceLoadDelegate:nil];
        [self.firstWebView.mainFrame loadHTMLString:self.firstHTMLCodeString baseURL:[NSURL URLWithString:self.URLStringForCode]];
        [self.secondeWebView.mainFrame loadHTMLString:self.secondeHTMLCodeString baseURL:[NSURL URLWithString:self.URLStringForCode]];

    }
    else {
        [self.firstWebView setResourceLoadDelegate:self];
        [self.secondeWebView setResourceLoadDelegate:self];
        [self.firstWebView.mainFrame loadHTMLString:self.firstHTMLCodeString baseURL:nil];
        [self.secondeWebView.mainFrame loadHTMLString:self.secondeHTMLCodeString baseURL:nil];
    }
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    //Wird nur gesagt dass er keine Resourcen laden soll.
    return nil;
}

@end

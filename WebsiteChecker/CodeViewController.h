//
//  CodeViewController.h
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 20.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@class URLFile;
@interface CodeViewController : NSObject {
    NSLock* _lock;
}
@property (retain, nonatomic) URLFile* urlFile;


@property (assign) IBOutlet NSTextView *firstHTMLCodeView;
@property (assign) IBOutlet NSTextView *secondeHTMLCodeView;

@property (assign) IBOutlet WebView *firstWebView;
@property (assign) IBOutlet WebView *secondeWebView;

@property (assign) IBOutlet NSTabViewItem *tabViewItemWeb;
@property (assign) IBOutlet NSTabViewItem *tabViewItemCode;

@property (assign) IBOutlet NSButton *shouldLoadResourcesCheckBox;
@property (assign) IBOutlet NSProgressIndicator *comparStringProgressBar;

@property (retain, nonatomic) NSString* firstHTMLCodeString;
@property (retain, nonatomic) NSString* secondeHTMLCodeString;

@property (retain, nonatomic) NSString* URLStringForCode;
@property (retain, nonatomic) NSMutableArray* differencesFromStringsArray;

- (void) updateComparStringProgressBar;
- (void) didSelectDate: (NSDate*) date forURL:(NSString*)url withComparDate:(NSDate*) comparDate;
@end

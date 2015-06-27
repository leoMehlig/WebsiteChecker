//
//  URLFile.m
//  WebsiteChecker
//
//  Created by Leonard Mehlig on 19.02.14.
//  Copyright (c) 2014 Leonard Mehlig. All rights reserved.
//

#import "URLFile.h"
#import "DateFile.h"
#import "Refresher.h"
#import "DatePathsItems.h"
static URLFile* _sharedURLFile;
@implementation URLFile

#pragma mark - Variablen
- (Refresher *)refresher
{
    if(!_refresher) _refresher = [Refresher sharedRefresher];
    return _refresher;
}
- (DateFile *)dateFile
{
    if (!_dateFile) _dateFile = [[DateFile alloc]init];
    return _dateFile;
}
+ (instancetype)sharedURLFile
{
    if (!_sharedURLFile) _sharedURLFile = [[URLFile alloc]init];
    return _sharedURLFile;
}

- (NSMutableArray *)threadArray
{
    if (!_threadArray) _threadArray = [[NSMutableArray alloc]init];
    return _threadArray;
}
- (NSMutableDictionary *)loadingURLs
{
    if (!_loadingURLs) _loadingURLs = [[NSMutableDictionary alloc]init];
    return _loadingURLs;
}

- (NSMutableArray *)urls
{
    
    if (!_urls) _urls = [[NSMutableArray alloc]init];
    [_urls removeAllObjects];
    for (DatePathsItems* datePathItem in self.datePaths) {
        [_urls addObject:datePathItem.url];
    }
    
    return _urls;
}

- (NSMutableArray *)datePaths
{
    if (!_datePaths)
    {
        _datePaths = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePathWithPathComponent:@"websiteCheckerDatePathsArray"]];
        
        if (!_datePaths) _datePaths = [[NSMutableArray alloc]init];
        else [_datePaths retain];
    }
    return _datePaths;
}

- (NSString*) datePathForURL:(NSString*)url
{
    [self reloadDatePaths];
    for (DatePathsItems* datePathItem in self.datePaths) {
        if ([datePathItem.url isEqualToString:url]) {
            NSString* datePath = datePathItem.path;
            if (![datePath isKindOfClass:[NSString class]]) {
                NSLog(@"Is not menber of class. %@", datePath);
                return nil;
            }
            return datePath;
        }
    }
    NSLog(@"%s DatePath for URL: %@ not found",__PRETTY_FUNCTION__, url);
    return nil;
}

- (NSMutableArray *)datesForURLString:(NSString *)url
{
    NSString* path = [self datePathForURL:url];
    if (!path) {
        NSLog(@"%s DatePath for URL: %@ not found",__PRETTY_FUNCTION__, url);
        return nil;
    }
    NSMutableArray* dates = [[NSMutableArray alloc]init];
    for (NSDictionary* dateAndCodePathDict in [self.dateFile datesForPath:path]) {
        [dates addObject:dateAndCodePathDict[DATEKEY]];
    }
    [dates autorelease];
    return dates;
    
}
- (NSString *)codeForURL:(NSString *)url forDate:(NSDate *)date
{
    NSString* datePath = [self datePathForURL:url];
    if (!datePath){
        NSLog(@"%s DatePath for URL: %@ not found",__PRETTY_FUNCTION__, url);
        return nil;
    }
    return [self.dateFile codeForDate:date inPath:datePath];
    
}
- (NSString*) uniqueID
{
    return  [[NSProcessInfo processInfo] globallyUniqueString];;
}

- (NSString*) dataFilePathWithPathComponent:(NSString*)pathComponent
{
    if (![pathComponent isKindOfClass:[NSString class]]) {
        NSLog(@"Is not menber of class. %@", pathComponent);
        return nil;
    }
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    path = [path stringByExpandingTildeInPath];
    NSError* error = nil;
    if (![fileManager fileExistsAtPath:path]) [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) NSLog(@"CreatDictAtPath-Error:%@", error);
    return [path stringByAppendingPathComponent:pathComponent];
}


- (void) removeURL:(NSString*) url
{
    [self.dateFile removeCodeForURL:url];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    [fileManager removeItemAtPath:[self dataFilePathWithPathComponent:[self datePathForURL:url]] error:&error];
    if (error) {
        NSLog(@"Delet Url: %@, Error: %@", url, error);
        return;
    }
    
    for (DatePathsItems* datePathItem in self.datePaths) {
        if ([datePathItem.url isEqualToString:url]) {
            [self.datePaths removeObject:datePathItem];
            break;
        }
    }
    [self saveDatePaths];
   }

- (BOOL)addURL:(NSString *)url withRefreshInterval:(double)intervalInSeconds withCode:(NSString *)code
{
    [_addUrlLock lock];
    NSString* path = [self.dateFile creatArrayWithDate:[NSDate date] withCode:code];
    if (path) {
        DatePathsItems* datePathItem = [[DatePathsItems alloc]initWithURL:url path:path interval:intervalInSeconds];
        [self.datePaths addObject:datePathItem];
        [self saveDatePaths];
        [self.refresher addWebsiteToRefreshTimer:datePathItem];
        [self.refresher setNextTimer];
        
        [datePathItem release];
        [_addUrlLock unlock];
        return YES;
    }
    NSLog(@"DatePath = nil");
    [_addUrlLock unlock];
    return NO;
}
#pragma mark - Refresh

- (BOOL) refreshURL:(NSString*)url
{
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.00];
    NSURLConnection* urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
    [urlConnection start];
    if (!urlConnection) {
        NSLog(@"Connection did Failed");
        
    }
    [urlConnection release];
    [urlRequest release];

    return YES;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   
    NSString* url = [connection.currentRequest.URL absoluteString];
    [url retain];
    
    NSString* path = [[self datePathForURL:url] retain];
    if (!path) {
        NSLog(@"No DatePath founded");
        
    }
    else {
        NSString* code = [[NSString alloc]initWithData:self.loadingURLs[connection.currentRequest.URL.absoluteString] encoding:NSUTF8StringEncoding];
        [self.dateFile addDate:[NSDate date] withCode:code toDatePath:path];
        [code release];
        [self saveDatePaths];
    }
    [path release];
    [url release];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"updateUI" object:nil];

}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData* loadingData = [self.loadingURLs objectForKey:connection.currentRequest.URL.absoluteString];

   NSLog(@" Current:%@ origanle: %@", connection.currentRequest.URL, connection.originalRequest.URL );
    if (loadingData){
    [loadingData appendData:data];
    } else {
        loadingData = [NSMutableData dataWithData:data];
        
    }
    [self.loadingURLs setObject:loadingData forKey:connection.currentRequest.URL.absoluteString];

}

- (void) refresh: (NSString*) url
{
    
        
   // [self.accessLock lock];
  /*
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [url retain];
    
    NSString* path = [[self datePathForURL:url] retain];
    if (!path) {
        NSLog(@"No DatePath founded");
    
    }
    else {
        [self.dateFile addDate:[NSDate date] withCode:[self codeForURL:url] toDatePath:path];
        [self saveDatePaths];
       [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    }
    [path release];
    [url release];
    [self.accessLock unlock];*/
}


- (void) updateUI
{
     NSLog(@"%s",__PRETTY_FUNCTION__);
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"updateUI" object:nil];
}


#pragma mark - Save/Load

- (void) saveDatePaths
{
    if ([NSKeyedArchiver archiveRootObject:self.datePaths toFile:[self dataFilePathWithPathComponent:@"websiteCheckerDatePathsArray"]]){
        //[self reloadDatePaths];
        return;
    }
    NSLog(@"DatePaths archiving failed");
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.datePaths forKey:@"websiteCheckerDatePathsArray"];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (!_accessLock) _accessLock = [[NSLock alloc] init];
        if (!_addUrlLock) _addUrlLock = [[NSLock alloc]init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        if (!_accessLock) _accessLock = [[NSLock alloc] init];
        if (!_addUrlLock) _addUrlLock = [[NSLock alloc]init];
        self.datePaths = [aDecoder decodeObjectForKey:@"websiteCheckerDatePathsArray"];
    }
    return self;
}

- (void) reloadDatePaths
{
    //[self.accessLock lock];
    [self.datePaths removeAllObjects];
     self.datePaths = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePathWithPathComponent:@"websiteCheckerDatePathsArray"]];
   // [self.accessLock unlock];
}
- (void)dealloc
{
    [_accessLock release];
    [_dateFile release];
    [_datePaths release];
    [_urls release];
    [_threadArray release];
    [_loadingURLs release];
    [super dealloc];
}
@end

//
//  SynJsBridgeWebview.m
//  dspider
//
//  Created by 杜文 on 16/12/30.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "DWebview.h"

@interface DWebview ()
@property (weak) id webview;
@end

@implementation DWebview
{
    void(^javascriptContextInitedListener)(void);
    //NSString * ua;
    
}

@synthesize webview;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        id wv;
        if ([[UIDevice currentDevice].systemVersion floatValue] >=8.0) {
            wv=[[DWKwebview alloc] initWithFrame:frame];
        }else{
            wv=[[DUIwebview alloc] initWithFrame:frame];
        }
        [self addSubview:wv];
        webview=wv;
    }
    return self;
}

- (id _Nullable) getXWebview
{
    return webview;
}

- (void)loadRequest:(NSURLRequest *)request
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview loadRequest:request];
    }else{
        [(DWKwebview *)webview loadRequest:request];
    }
}



- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview loadHTMLString:string baseURL:baseURL];
    }else{
        [(DWKwebview *)webview loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    }else{
        [(DWKwebview *)webview loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    }
}

-(BOOL)canGoBack
{
    if([webview isKindOfClass:[DUIwebview class]]){
        return ((DUIwebview *)webview).canGoBack;
    }else{
        return ((DWKwebview *)webview).canGoBack;
    }
}

-(BOOL)canGoForward
{
    if([webview isKindOfClass:[DUIwebview class]]){
        return ((DUIwebview *)webview).canGoForward;
    }else{
        return ((DWKwebview *)webview).canGoForward;
    }
}

-(BOOL)isLoading
{
    if([webview isKindOfClass:[DUIwebview class]]){
        return ((DUIwebview *)webview).isLoading;
    }else{
        return ((DWKwebview *)webview).isLoading;
    }
}

-(void)reload
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview reload];
    }else{
        [(DWKwebview *)webview reload];
    }
}

- (void)stopLoading
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview stopLoading];
    }else{
        [(DWKwebview *)webview stopLoading];
    }
}

-(void)setJavascriptInterfaceObject:(id)jsib
{
    if([webview isKindOfClass:[DUIwebview class]]){
        ((DUIwebview *)webview).JavascriptInterfaceObject=jsib;
    }else{
        ((DWKwebview *)webview).JavascriptInterfaceObject=jsib;
    }
}

- (void)loadUrl: (NSString *)url
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self loadRequest:request];//加载
}

- (void)setJavascriptContextInitedListener:(void (^)(void))callback
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview setJavascriptContextInitedListener:callback];
    }else{
        [(DWKwebview *)webview setJavascriptContextInitedListener:callback];
    }
    
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *))completionHandler
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview  evaluateJavaScript:javaScriptString completionHandler:^(NSString * result){
            if(completionHandler) completionHandler(result);
        }];
    }else{
        [(DWKwebview *)webview evaluateJavaScript:javaScriptString completionHandler:^(NSString * result, NSError * error){
            if(completionHandler ) completionHandler(result);
        }];
    }
}

-(void)callHandler:(NSString *)methodName arguments:(NSArray *)args completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview callHandler:methodName arguments:args completionHandler:completionHandler];
    }else{
        [(DWKwebview *)webview callHandler:methodName arguments:args completionHandler:completionHandler];
    }
}


- (void)clearCache
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes= [NSSet setWithArray:@[
                                                       WKWebsiteDataTypeDiskCache,
                                                       //WKWebsiteDataTypeOfflineWebApplication
                                                       WKWebsiteDataTypeMemoryCache,
                                                       //WKWebsiteDataTypeLocal
                                                       WKWebsiteDataTypeCookies,
                                                       //WKWebsiteDataTypeSessionStorage,
                                                       //WKWebsiteDataTypeIndexedDBDatabases,
                                                       //WKWebsiteDataTypeWebSQLDatabases
                                                       ]];
        
        // All kinds of data
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
        
    } else {
        //先删除cookie
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        
        NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSString *webKitFolderInCachesfs = [NSString
                                            stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
        /* iOS7.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
        NSString *cookiesFolderPath = [libraryDir stringByAppendingString:@"/Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
    }
    
}

@end

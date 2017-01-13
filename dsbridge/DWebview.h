//
//  SynJsBridgeWebview.h
//  dspider
//
//  Created by 杜文 on 16/12/30.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWKwebview.h"
#import "DUIwebview.h"
NS_ASSUME_NONNULL_BEGIN
@interface DWebview : UIView
@property(nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property(nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property(nonatomic, readonly, strong)NSURLRequest * _Nonnull request;
@property(nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nullable, nonatomic, weak,setter=setJavascriptInterfaceObject:) id JavascriptInterfaceObject ;

- (id _Nullable) getXWebview;

- (void)loadUrl: (NSString *) url;
- (void)loadRequest:(NSURLRequest * )request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

- (void)stopLoading;
- (void)reload;

- (void)setJavascriptContextInitedListener:(void (^)(void))callback;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(NSString *result))completionHandler;
-(void)callHandler:(NSString *)methodName arguments:(NSArray * _Nullable)args completionHandler:(void (^)(NSString *  _Nullable))completionHandler;

- (void) clearCache;



@end
NS_ASSUME_NONNULL_END

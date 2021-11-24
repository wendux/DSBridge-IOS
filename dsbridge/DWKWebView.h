//
//  DSWKwebview.h
//  dspider
//
//  Created by 杜文 on 16/12/28.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <WebKit/WebKit.h>

typedef void (^JSCallback)(NSString *_Nullable result, BOOL complete);

@interface DWKWebView : WKWebView <WKUIDelegate>

/// Delegate
@property (nullable, nonatomic, weak) id<WKUIDelegate> DSUIDelegate;

/// Load web  use the url.
/// @param url the url of the web page.
- (void)loadUrl:(NSString *_Nonnull)url;

/// Call javascript method
/// @param methodName js called method name.
/// @param args the method's args.
- (void)callHandler:(NSString *_Nonnull)methodName arguments:(NSArray *_Nullable)args;

/// Call javascript method
/// @param methodName  js called method name.
/// @param completionHandler completion handler block.
- (void)callHandler:(NSString *_Nonnull)methodName completionHandler:(void (^_Nullable)(id _Nullable value))completionHandler;


/// Call javascript method
/// @param methodName  js called method name.
/// @param args the method's args.
/// @param completionHandler completion handler block.
- (void)callHandler:(NSString *_Nonnull)methodName
          arguments:(NSArray *_Nullable)args
  completionHandler:(void (^_Nullable)(id _Nullable value))completionHandler;

// set a listener for javascript closing the current page.
- (void)setJavascriptCloseWindowListener:(void (^_Nullable)(void))callback;

/**
 * Add a Javascript Object to dsBridge with namespace.
 * @param object
 * which implemented the javascript interfaces
 * @param namespace  
 * if empty, the object have no namespace.
 **/
- (void)addJavascriptObject:(id _Nullable)object namespace:(NSString *_Nullable)namespace;

// Remove the Javascript Object with the supplied namespace
- (void)removeJavascriptObject:(NSString *_Nullable)namespace;

// Test whether the handler exist in javascript
- (void)hasJavascriptMethod:(NSString *_Nonnull)handlerName methodExistCallback:(void (^_Nullable)(bool exist))callback;

// Set debug mode. if in debug mode, some errors will be prompted by a dialog
// and the exception caused by the native handlers will not be captured.
- (void)setDebugMode:(bool)debug;

- (void)disableJavascriptDialogBlock:(bool)disable;

// custom the  label text of  javascript dialog that includes alert/confirm/prompt
- (void)customJavascriptDialogLabelTitles:(NSDictionary *_Nullable)dic;

// private method, the developer shoudn't call this method
- (id _Nullable)onMessage:(NSDictionary *_Nonnull)msg type:(int)type;

@end

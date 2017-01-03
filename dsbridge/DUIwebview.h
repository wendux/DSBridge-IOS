//
//  DSUIwebview.h
//  dspider
//
//  Created by 杜文 on 16/12/30.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBWebEventDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface DUIwebview: UIWebView<UIWebViewDelegate>{
    void(^javascriptContextInitedListener)();
}
- (void)loadUrl: (NSString * _Nonnull) url;
- (void)setJavascriptContextInitedListener:(void(^_Nullable)(void))callback;
- (void)evaluateJavaScript:(NSString * _Nonnull)javaScriptString completionHandler:(void (^ _Nullable)(NSString * _Nullable))completionHandler;
-(void) callHandler:(NSString * _Nonnull) methodName  arguments:(NSArray * _Nullable) args completionHandler:(void (^ _Nullable)(NSString * _Nullable ))completionHandler;

@property (nullable, nonatomic, weak) id<JSBWebEventDelegateProtocol> WebEventDelegate;
@property (nullable, nonatomic, weak) id JavascriptInterfaceObject ;
@end

//
//  DSWKwebview.h
//  dspider
//
//  Created by 杜文 on 16/12/28.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface DWKwebview : WKWebView <WKUIDelegate,WKNavigationDelegate,UIAlertViewDelegate >
{
    bool confirmDone;
    BOOL confirmResult;
    void(^javascriptContextInitedListener)(void);
    
}
@property (nullable, nonatomic, weak) id <WKUIDelegate> DSUIDelegate;
@property (nullable, nonatomic, weak) id JavascriptInterfaceObject;
- (void)loadUrl: (NSString * _Nonnull) url;
-(void) callHandler:(NSString * _Nonnull) methodName  arguments:(NSArray * _Nullable) args completionHandler:(void (^ _Nullable)(NSString *  _Nullable))completionHandler;
- (void)setJavascriptContextInitedListener:(void(^_Nullable)(void))callback;
@end

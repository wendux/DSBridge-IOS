//
//  DSWKwebview.m
//  dspider
//
//  Created by 杜文 on 16/12/28.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "DWKwebview.h"
#import "JSBUtil.h"

@implementation DWKwebview

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    //NSString * js=@"function setupWebViewJavascriptBridge(b){var a={call:function(d,c){return prompt('_dspiercall='+d,c)}};b(a)};";
    
    NSString * js=[@"_dswk='_dsbridge=';" stringByAppendingString: INIT_SCRIPT];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    WKUserScript *scriptDomReady = [[WKUserScript alloc] initWithSource:@";prompt('_dsinited');"
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                       forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:scriptDomReady];
    self = [super initWithFrame:frame configuration: configuration];
    if (self) {
        super.UIDelegate=self;
    }
    return self;
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    NSString * prefix=@"_dsbridge=";
    if ([prompt hasPrefix:prefix])
    {
        NSString *method= [prompt substringFromIndex:[prefix length]];
        NSString *result =[JSBUtil call:method :defaultText JavascriptInterfaceObject:_JavascriptInterfaceObject jscontext:webView];
        completionHandler(result);
    }else if([prompt hasPrefix:@"_dsinited"]){
        completionHandler(@"");
        if(javascriptContextInitedListener) javascriptContextInitedListener();
        
    }else {
        if(self.DSUIDelegate && [self.DSUIDelegate respondsToSelector:
                                 @selector(webView:runJavaScriptTextInputPanelWithPrompt
                                           :defaultText:initiatedByFrame
                                           :completionHandler:)])
        {
            return [self.DSUIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt
                                  defaultText:defaultText
                             initiatedByFrame:frame
                            completionHandler:completionHandler];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prompt message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *txtName = [alert textFieldAtIndex:0];
            txtName.text=defaultText;
            [alert show];
            while (!confirmDone){
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            confirmDone=false;
            completionHandler([txtName text]);
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    if( self.DSUIDelegate &&  [self.DSUIDelegate respondsToSelector:
                               @selector(webView:runJavaScriptAlertPanelWithMessage
                                         :initiatedByFrame:completionHandler:)])
    {
        return [self.DSUIDelegate webView:webView runJavaScriptAlertPanelWithMessage:message
                         initiatedByFrame:frame
                        completionHandler:completionHandler];
    }else{
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"提示"
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil,nil];
        completionHandler();
        [alertView show];
    }
}

-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    if( self.DSUIDelegate && [self.DSUIDelegate respondsToSelector:
                              @selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)])
    {
        return[self.DSUIDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message
                        initiatedByFrame:frame
                       completionHandler:completionHandler];
    }else{
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"提示"
                                   message:message
                                  delegate:self
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@"确定", nil];
        [alertView show];
        while (!confirmDone){
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        confirmDone=false;
        completionHandler(confirmResult);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    confirmDone=true;
    confirmResult=buttonIndex==1?YES:NO;
}

- (void)setJavascriptContextInitedListener:(void (^)(void))callback
{
    javascriptContextInitedListener=callback;
}

- (void)loadUrl: (NSString *)url
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self loadRequest:request];//加载
}

-(void)callHandler:(NSString *)methodName arguments:(NSArray *)args completionHandler:(void (^)(NSString *  _Nullable))completionHandler
{
    if(!args){
        args=[[NSArray alloc] init];
    }
    NSString *script=[NSString stringWithFormat:@"%@.apply(null,%@)",methodName,[JSBUtil objToJsonString:args]];
    [self evaluateJavaScript:script completionHandler:^(id value,NSError * error){
        if(completionHandler) completionHandler(value);
    }];
}

@end



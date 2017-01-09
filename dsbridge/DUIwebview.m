//
//  DSUIwebview.m
//  dspider
//
//  Created by 杜文 on 16/12/30.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "DUIwebview.h"
#import "JSBUtil.h"
#import <objc/runtime.h>

static const char kTSJavaScriptContext[] = "ts_javaScriptContext";
static NSHashTable* g_webViews = nil;

@interface UIWebView (TS_JavaScriptCore_private)
- (void) ts_didCreateJavaScriptContext:(JSContext *)ts_javaScriptContext;
@end

@protocol TSWebFrame <NSObject>
- (id) parentFrame;
@end

@implementation NSObject (TS_JavaScriptContext)

- (void) webView: (id) unused didCreateJavaScriptContext: (JSContext*) ctx forFrame: (id<TSWebFrame>) frame
{
    NSParameterAssert( [frame respondsToSelector: @selector( parentFrame )] );
    // only interested in root-level frames
    if ( [frame respondsToSelector: @selector( parentFrame) ] && [frame parentFrame] != nil )
        return;
    
    void (^notifyDidCreateJavaScriptContext)() = ^{
        
        for ( UIWebView* webView in g_webViews )
        {
            NSString* cookie = [NSString stringWithFormat: @"ts_jscWebView_%lud", (unsigned long)webView.hash ];
            
            [webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie ] ];
            
            if ( [ctx[cookie].toString isEqualToString: cookie] )
            {
                
                [webView  willChangeValueForKey: @"ts_javaScriptContext"];
                objc_setAssociatedObject( webView , kTSJavaScriptContext, ctx, OBJC_ASSOCIATION_RETAIN);
                [webView didChangeValueForKey: @"ts_javaScriptContext"];
                if ( [webView.delegate respondsToSelector: NSSelectorFromString(@"webView:didCreateJavaScriptContext:")] )
                {
                    SuppressPerformSelectorLeakWarning(
                                                       [webView performSelector:NSSelectorFromString(@"webView:didCreateJavaScriptContext:") withObject:webView withObject:ctx ] ;//webView: webView didCreateJavaScriptContext: ctx];
                                                       );
                }
                return;
            }
        }
    };
    
    if ( [NSThread isMainThread] )
    {
        notifyDidCreateJavaScriptContext();
    }
    else
    {
        dispatch_async( dispatch_get_main_queue(), notifyDidCreateJavaScriptContext );
    }
}

@end


@implementation DUIwebview
@synthesize WebEventDelegate,JavascriptInterfaceObject;

+ (id) allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_webViews = [NSHashTable weakObjectsHashTable];
    });
    NSAssert( [NSThread isMainThread], @"uh oh - why aren't we on the main thread?");
    id webView = [super allocWithZone: zone];
    [g_webViews addObject: webView];
    return webView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.scalesPageToFit=YES;
        self.delegate=self;
    }
    return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    __block  JSContext * ctx_=ctx;
    ctx[@"_dsbridge"]=^(NSString * method,NSString * args){
        return [JSBUtil call:method :args JavascriptInterfaceObject:JavascriptInterfaceObject jscontext:ctx_];
    };
    [ctx evaluateScript:INIT_SCRIPT];
}

- (void)setJavascriptContextInitedListener:(void (^)(void))callback
{
    javascriptContextInitedListener=callback;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *))completionHandler
{
    NSString *js_result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if(completionHandler) completionHandler(js_result);
}

-(void)callHandler:(NSString *)methodName arguments:(NSArray *)args completionHandler:(void (^)(NSString *))completionHandler
{
    if(!args){
        args=[[NSArray alloc] init];
    }
    NSString *script=[NSString stringWithFormat:@"%@.apply(window,%@)",methodName,[JSBUtil objToJsonString:args]];
    [self evaluateJavaScript:script completionHandler:^(NSString * value){
        if(completionHandler) completionHandler(value);
    }];
}

- (void)loadUrl: (NSString *)url
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self loadRequest:request];//加载
}

//UIWebviewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(javascriptContextInitedListener){
        javascriptContextInitedListener();
    }
    if([WebEventDelegate respondsToSelector:NSSelectorFromString(@"onpageFinished:")]){
        [WebEventDelegate onpageFinished: [webView.request.URL absoluteString]];
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    if([WebEventDelegate respondsToSelector:NSSelectorFromString(@"onPageStart:")]){
        [WebEventDelegate onPageStart:[webView.request.URL absoluteString]];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([WebEventDelegate respondsToSelector: NSSelectorFromString(@"onpageError::")]){
        [WebEventDelegate onpageError:[webView.request.URL absoluteString] :[error localizedDescription]];
    }
}
@end

//
//  Util.m
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "JSBUtil.h"
#import "DWebview.h"

@implementation JSBUtil
+ (NSString *)objToJsonString:(id)dict
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (! jsonData) {
        return @"{}";
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

UInt64 g_ds_last_call_time = 0;
NSString *g_ds_js_cache=@"";
bool g_ds_have_pending=false;

+(NSString *)call:(NSString*) method :(NSString*) args  JavascriptInterfaceObject:(id) JavascriptInterfaceObject jscontext:(id) jscontext
{
    SEL sel=NSSelectorFromString([method stringByAppendingString:@":"]);
    SEL selasyn=NSSelectorFromString([method stringByAppendingString:@"::"]);
    NSString *error=[NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",method];
    NSString *result=@"";
    if(!JavascriptInterfaceObject){
        NSLog(@"Js bridge method called, but there is not a JavascriptInterfaceObject, please set JavascriptInterfaceObject first!");
    }else{
        NSDictionary * json=[JSBUtil jsonStringToObject:args];
        NSString * cb;
        do{
            if(json && (cb= [json valueForKey:@"_dscbstub"])){
                if([JavascriptInterfaceObject respondsToSelector:selasyn]){
                    void (^completionHandler)(NSString *) = ^(NSString * value){
                        value=[value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                        NSString*js=[NSString stringWithFormat:@"try {%@(decodeURIComponent(\"%@\"));delete window.%@; } catch(e){};",cb,(value == nil) ? @"" : value,cb];
                        if([jscontext isKindOfClass:JSContext.class]){
                            [jscontext evaluateScript:js ];
                        }else if([jscontext isKindOfClass:WKWebView.class]){
                            @synchronized(jscontext)
                            {
                                UInt64  t=[[NSDate date] timeIntervalSince1970]*1000;
                                g_ds_js_cache=[g_ds_js_cache stringByAppendingString:js];
                                if(t-g_ds_last_call_time<50){
                                    if(!g_ds_have_pending){
                                        [self evalJavascript:(WKWebView *)jscontext :50];
                                        g_ds_have_pending=true;
                                    }
                                }else{
                                    [self evalJavascript:(WKWebView *)jscontext  :0];
                                }
                            }
                        }
                    };
                    SuppressPerformSelectorLeakWarning(
                                                       result=[JavascriptInterfaceObject performSelector:selasyn withObject:json withObject:completionHandler];
                                                       
                                                       );
                    //when performSelector is performing a selector that return value type is void,
                    //the return value of performSelector always seem to be the first argument of the selector in real device(simulator is nil).
                    //So,you should declare the return type of all api as NSString explicitly.
                    if(result==(id)json){
                        result=@"";
                    }
                    
                    break;
                }
            }else if([JavascriptInterfaceObject respondsToSelector:sel]){
                SuppressPerformSelectorLeakWarning(
                                                   result=[JavascriptInterfaceObject performSelector:sel withObject:json];
                                                   );
                break;
            }
            NSString*js=[error stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            js=[NSString stringWithFormat:@"window.alert(decodeURIComponent(\"%@\"));",js];
            if([jscontext isKindOfClass:JSContext.class]){
                [jscontext evaluateScript:js ];
            }else if([jscontext isKindOfClass:WKWebView.class]){
                [(WKWebView *)jscontext evaluateJavaScript :js completionHandler:nil];
            }
            NSLog(@"%@",error);
        }while (0);
    }
    if(result == nil||![result isKindOfClass:[NSString class]]){
        result=@"";
    }
    return result;
}

+ (void) evalJavascript:(WKWebView *)jscontext :(int) delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        //NSLog(@"\%@\n",g_ds_js_cache);
        @synchronized(jscontext){
            if([g_ds_js_cache length]!=0){
                [(WKWebView *)jscontext evaluateJavaScript :g_ds_js_cache completionHandler:nil];
                g_ds_have_pending=false;
                g_ds_js_cache=@"";
                g_ds_last_call_time=[[NSDate date] timeIntervalSince1970]*1000;
            }
        }
    });
}


+ (id )jsonStringToObject:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

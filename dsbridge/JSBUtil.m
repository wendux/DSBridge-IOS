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

+(NSString *)call:(NSString*) method :(NSString*) args  JavascriptInterfaceObject:(id) JavascriptInterfaceObject jscontext:(id) jscontext
{
    SEL sel=NSSelectorFromString([method stringByAppendingString:@":"]);
    SEL selasyn=NSSelectorFromString([method stringByAppendingString:@"::"]);
    NSString *error=[NSString stringWithFormat:@"Error! \n Method %@ is not invoked, since there is not a implementation for it",method];
    NSString *result;
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
                        NSString*js=[NSString stringWithFormat:@"%@(decodeURIComponent(\"%@\"));delete window.%@",cb,(value == nil) ? @"" : value,cb];
                        if([jscontext isKindOfClass:JSContext.class]){
                            [jscontext evaluateScript:js ];
                        }else if([jscontext isKindOfClass:WKWebView.class]){
                            [(WKWebView *)jscontext evaluateJavaScript :js completionHandler:nil];
                        }
                    };
                    SuppressPerformSelectorLeakWarning(
                    result=[JavascriptInterfaceObject performSelector:selasyn withObject:json withObject:completionHandler];
                                                       );
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
    return (result == nil) ? @"" : result;
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

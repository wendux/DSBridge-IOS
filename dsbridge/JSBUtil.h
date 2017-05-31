//
//  Util.h
//  dspider
//
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWebview.h"

static NSString * _Nonnull INIT_SCRIPT=@"function getJsBridge(){window._dsf=window._dsf||{};return{call:function(b,a,c){'function'==typeof a&&(c=a,a={});if('function'==typeof c){window.dscb=window.dscb||0;var d='dscb'+window.dscb++;window[d]=c;a._dscbstub=d}a=JSON.stringify(a||{});return window._dswk?prompt(window._dswk+b,a):'function'==typeof _dsbridge?_dsbridge(b,a):_dsbridge.call(b,a)},register:function(b,a){'object'==typeof b?Object.assign(window._dsf,b):window._dsf[b]=a}}}dsBridge=getJsBridge()";

#define SuppressPerformSelectorLeakWarning(Stuff) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
}

@interface JSBUtil : NSObject
+ (NSString * _Nullable)objToJsonString:(id  _Nonnull)dict;
+ (id  _Nullable)jsonStringToObject:(NSString * _Nonnull)jsonString;
+ (NSString * _Nullable)call:(NSString* _Nonnull) method :(NSString* _Nonnull) args  JavascriptInterfaceObject:(id _Nonnull) JavascriptInterfaceObject jscontext:(id _Nonnull) jscontext;

@end

//
//  Util.h
//  dspider
//
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWebview.h"

static NSString * _Nonnull INIT_SCRIPT=@"function getJsBridge(){return{call:function(e,c,a){var b='';if(typeof c=='function'){a=c;c={}}if(typeof a=='function'){window.dscb=window.dscb||0;var d='dscb'+window.dscb++;window[d]=a;c._dscbstub=d}c=JSON.stringify(c||{});if(window._dswk){b=prompt(window._dswk+e,c)}else{if(typeof _dsbridge=='function'){b=_dsbridge(e,c)}else{b=_dsbridge.call(e,c)}}return b}}};";

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

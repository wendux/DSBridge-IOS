//
//  Util.m
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "JSBUtil.h"
#import <objc/runtime.h>
#import "DWKWebView.h"

/// 缓存类的方法
static NSMutableDictionary *_JSBUtilClassMethodsCache;

@implementation JSBUtil
+ (NSString *)objToJsonString:(id)dict
{
    NSString *jsonString = nil;
    NSError *error;
    
    // judgement ---HaoCold 2018-08-23 09:42:09
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        return @"{}";
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (! jsonData) {
        return @"{}";
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

//get this class all method
#if 0
+(NSArray *)allMethodFromClass:(Class)class
{
    NSMutableArray *arr = [NSMutableArray array];
    u_int count;
    Method *methods = class_copyMethodList(class, &count);
    for (int i =0; i<count; i++) {
        SEL name1 = method_getName(methods[i]);
        const char *selName= sel_getName(name1);
        NSString *strName = [NSString stringWithCString:selName encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",strName);
        [arr addObject:strName];
    }
    free(methods);
    return arr;
}
#else
+(NSArray *)allMethodFromClass:(Class)class
{
    // fetch from cache
    NSString *key = NSStringFromClass(class);
    NSArray *allMethods = [_JSBUtilClassMethodsCache valueForKey:key];
    if (allMethods) {
        return allMethods;
    }
    
    // fetch from protocol
    NSArray *array;
    NSMutableSet *methodSet = [NSMutableSet set];
    Class cls = [class class];
    id obj = [cls new];
    while ([obj respondsToSelector:@selector(ds_allMethodsForJS)]) {
        NSArray *array = [obj performSelector:@selector(ds_allMethodsForJS)];
        [methodSet addObjectsFromArray:array];
        
        cls = class_getSuperclass(cls);
        obj = [cls new];
    }
    array = methodSet.allObjects;
    
    // fetch from class, superclass...
    if (!array) {
        NSString *className = NSStringFromClass(class);
        NSMutableSet *methods = [NSMutableSet set];
        while (class) {
            unsigned int count = 0;
            Method *method = class_copyMethodList(class, &count);
            for (unsigned int i = 0; i < count; i++) {
                SEL name1 = method_getName(method[i]);
                const char *selName= sel_getName(name1);
                NSString *strName = [NSString stringWithCString:selName encoding:NSUTF8StringEncoding];
                [methods addObject:strName];
            }
            free(method);
            
            Class cls = class_getSuperclass(class);
            className = NSStringFromClass(cls);
            class = [className hasPrefix:@"NS"]?nil:cls;
        }
        
        array = methods.allObjects;
    }
    
    if (!_JSBUtilClassMethodsCache) {
        _JSBUtilClassMethodsCache = @{}.mutableCopy;
    }
    
    [_JSBUtilClassMethodsCache setValue:array forKey:key];
    
    return array;
}
#endif

//return method name for xxx: or xxx:handle:
+(NSString *)methodByNameArg:(NSInteger)argNum selName:(NSString *)selName class:(Class)class
{
    NSString *result = nil;
    if(class){
        NSArray *arr = [JSBUtil allMethodFromClass:class];
        for (int i=0; i<arr.count; i++) {
            NSString *method = arr[i];
            NSArray *tmpArr = [method componentsSeparatedByString:@":"];
            if ([method hasPrefix:selName]&&tmpArr.count==(argNum+1)) {
                result = method;
                return result;
            }
        }
    }
    return result;
}

+ (NSArray *)parseNamespace: (NSString *) method{
    NSRange range=[method rangeOfString:@"." options:NSBackwardsSearch];
    NSString *namespace=@"";
    if(range.location!=NSNotFound){
        namespace=[method substringToIndex:range.location];
        method=[method substringFromIndex:range.location+1];
    }
    return @[namespace,method];
    
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

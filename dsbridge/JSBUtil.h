//
//  Util.h
//  dspider
//
//  Created by 杜文 on 16/12/27.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
}

enum{
 DSB_API_HASNATIVEMETHOD,
 DSB_API_CLOSEPAGE,
 DSB_API_RETURNVALUE,
 DSB_API_DSINIT,
 DSB_API_DISABLESAFETYALERTBOX
};

@interface JSBUtil : NSObject
+ (NSString * _Nullable)objToJsonString:(id  _Nonnull)dict;
+ (id  _Nullable)jsonStringToObject:(NSString * _Nonnull)jsonString;
+(NSString *_Nullable)methodByNameArg:(NSInteger)argNum
                              selName:( NSString * _Nullable)selName class:(Class _Nonnull )class;
+ (NSArray *_Nonnull)parseNamespace: (NSString *_Nonnull) method;
@end

#import <Foundation/Foundation.h>

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

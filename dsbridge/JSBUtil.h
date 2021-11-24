#import <Foundation/Foundation.h>

enum {
    DSB_API_HASNATIVEMETHOD,
    DSB_API_CLOSEPAGE,
    DSB_API_RETURNVALUE,
    DSB_API_DSINIT,
    DSB_API_DISABLESAFETYALERTBOX
};

@interface JSBUtil : NSObject

/// Objct are converted to JSON strings
/// @param dict An object that needs to be converted to a JSON string, usually is dictionary.
+ (NSString *_Nullable)objToJsonString:(id _Nonnull)dict;

/// Json strings are converted to dictionaries
/// @param jsonString  Json string that needs to be converted into a dictionary.
+ (id _Nullable)jsonStringToObject:(NSString *_Nonnull)jsonString;

/// Combine method names based on supplied parameters
/// @param argNum  argment count.
/// @param selName selector name.
/// @param objClass objc's class.
+ (NSString *_Nullable)methodByNameArg:(NSInteger)argNum selName:(NSString *_Nullable)selName objClass:(Class _Nonnull)objClass;

/// Parse the namespace
/// @param method namespace of method
+ (NSArray *_Nonnull)parseNamespace:(NSString *_Nonnull)method;

@end

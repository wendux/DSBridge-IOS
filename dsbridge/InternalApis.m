//
//  InternalApis.m
//  dsbridge
//
//  Created by du on 2018/1/30.
//  Copyright © 2018年 杜文. All rights reserved.
//

#import "InternalApis.h"
#import "JSBUtil.h"

@implementation InternalApis

- (NSArray *)ds_allMethodsForJS{
    return @[@"hasNativeMethod:",
             @"closePage:",
             @"returnValue:",
             @"dsinit:",
             @"disableJavascriptDialogBlock:"];
}

- (id) hasNativeMethod:(id) args
{
    return [self.webview onMessage:args type: DSB_API_HASNATIVEMETHOD];
}

- (id) closePage:(id) args{
    return [self.webview onMessage:args type:DSB_API_CLOSEPAGE];
}

- (id) returnValue:(NSDictionary *) args{
    return [self.webview onMessage:args type:DSB_API_RETURNVALUE];
}

- (id) dsinit:(id) args{
    return [self.webview onMessage:args type:DSB_API_DSINIT];
}

- (id) disableJavascriptDialogBlock:(id) args{
    return [self.webview onMessage:args type:DSB_API_DISABLESAFETYALERTBOX];
}
@end

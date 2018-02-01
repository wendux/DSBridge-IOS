//
//  JsEchoApi.m
//  dsbridge
//
//  Created by du on 2018/2/1.
//  Copyright © 2018 wendu. All rights reserved.
//

#import "JsEchoApi.h"

@implementation JsEchoApi

- (id) syn:(id) arg
{
    return arg;
}

- (void) asyn: (id) arg :(void (^)( id _Nullable result,BOOL complete))completionHandler
{
    completionHandler(arg,YES);
}

@end

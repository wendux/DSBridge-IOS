//
//  JsEchoApi.m
//  dsbridge
//
//  Created by du on 2018/2/1.
//  Copyright © 2018 wendu. All rights reserved.
//

#import "JsEchoApi.h"
#import "dsbridge.h"

@implementation JsEchoApi

- (id) syn:(id) arg
{
    return arg;
}

- (void) asyn: (id) arg :(JSCallback)completionHandler
{
    completionHandler(arg,YES);
}

@end

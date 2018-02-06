//
//  JsApiTest.m
//
//  Created by 杜文 on 16/12/30.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import "JsApiTest.h"

@interface JsApiTest(){
  NSTimer * timer ;
  void(^hanlder)(id value,BOOL isComplete);
  int value;
}
@end

@implementation JsApiTest

- (NSString *) testSyn:(NSString *) msg
{
    return [msg stringByAppendingString:@"[ syn call]"];
}

- (void) testAsyn:(NSString *) msg :(void (^)(NSString * _Nullable result,BOOL complete))completionHandler
{
    completionHandler([msg stringByAppendingString:@" [ asyn call]"],YES);
}

- (NSString *)testNoArgSyn:(NSDictionary *) args
{
    return  @"testNoArgSyn called [ syn call]";
}

- ( void )testNoArgAsyn:(NSDictionary *) args :(void (^)(NSString * _Nullable result,BOOL complete))completionHandler
{
    completionHandler(@"testNoArgAsyn called [ asyn call]",YES);
}

- ( void )callProgress:(NSDictionary *) args :(void (^)(NSNumber * _Nullable result,BOOL complete))completionHandler
{
    value=10;
    hanlder=completionHandler;
    timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(onTimer:)
                                            userInfo:nil
                                             repeats:YES];
}

-(void)onTimer:t{
    if(value!=-1){
        hanlder([NSNumber numberWithInt:value--],NO);
    }else{
        hanlder(0,YES);
        [timer invalidate];
    }
}

@end

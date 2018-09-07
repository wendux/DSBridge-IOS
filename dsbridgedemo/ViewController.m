//
//  ViewController.m
//  jsbridgedemo
//
//  Created by wendu on 17/1/1.
//  Copyright © 2017 wendu. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "JsEchoApi.h"
#import "dsbridgedemo-Swift.h"
@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds=self.view.bounds;
    DWKWebView * dwebview=[[DWKWebView alloc] initWithFrame:CGRectMake(0, 25, bounds.size.width, bounds.size.height-25)];
    [self.view addSubview:dwebview];
    
    // register api object without namespace
    [dwebview addJavascriptObject:[[JsApiTest alloc] init] namespace:nil];
    
    // register api object without namespace
    [dwebview addJavascriptObject:[[ JsApiTestSwift alloc] init] namespace:@"swift"];
    
    // register api object with namespace "echo"
    [dwebview addJavascriptObject:[[JsEchoApi alloc] init] namespace:@"echo"];
    
    // open debug mode, Release mode should disable this.
    [dwebview setDebugMode:true];
    
    [dwebview customJavascriptDialogLabelTitles:@{@"alertTitle":@"Notification",@"alertBtn":@"OK"}];
    
    dwebview.navigationDelegate=self;
    
    // load test.html
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"test"
                                                          ofType:@"html"];
    NSString * htmlContent = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [dwebview loadHTMLString:htmlContent baseURL:baseURL];
   
    // call javascript method
    [dwebview callHandler:@"addValue" arguments:@[@3,@4] completionHandler:^(NSNumber * value){
        NSLog(@"%@",value);
    }];

    [dwebview callHandler:@"append" arguments:@[@"I",@"love",@"you"] completionHandler:^(NSString * _Nullable value) {
       NSLog(@"call succeed, append string is: %@",value);
    }];

    // this invocation will be return 5 times
    [dwebview callHandler:@"startTimer" completionHandler:^(NSNumber * _Nullable value) {
        NSLog(@"Timer: %@",value);
    }];

    // namespace syn test
    [dwebview callHandler:@"syn.addValue" arguments:@[@5,@6] completionHandler:^(NSDictionary * _Nullable value) {
         NSLog(@"Namespace syn.addValue(5,6): %@",value);
    }];
    
    [dwebview callHandler:@"syn.getInfo" completionHandler:^(NSDictionary * _Nullable value) {
        NSLog(@"Namespace syn.getInfo: %@",value);
    }];
    
    // namespace asyn test
    [dwebview callHandler:@"asyn.addValue" arguments:@[@5,@6] completionHandler:^(NSDictionary * _Nullable value) {
        NSLog(@"Namespace asyn.addValue(5,6): %@",value);
    }];
    
    [dwebview callHandler:@"asyn.getInfo" completionHandler:^(NSDictionary * _Nullable value) {
        NSLog(@"Namespace asyn.getInfo: %@",value);
    }];
    
    // test if javascript method exists.
    [dwebview hasJavascriptMethod:@"addValue" methodExistCallback:^(bool exist) {
        NSLog(@"method 'addValue' exist : %d",exist);
    }];
    
    [dwebview hasJavascriptMethod:@"XX" methodExistCallback:^(bool exist) {
        NSLog(@"method 'XX' exist : %d",exist);
    }];
    
    [dwebview hasJavascriptMethod:@"asyn.addValue" methodExistCallback:^(bool exist) {
        NSLog(@"method 'asyn.addValue' exist : %d",exist);
    }];
    
    [dwebview hasJavascriptMethod:@"asyn.XX" methodExistCallback:^(bool exist) {
        NSLog(@"method 'asyn.XX' exist : %d",exist);
    }];
    
    // set javascript close listener
    [dwebview setJavascriptCloseWindowListener:^{
        NSLog(@"window.close called");
    } ];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

//
//  ViewController.m
//  jsbridgedemo
//
//  Created by 杜文 on 17/1/1.
//  Copyright © 2017年 杜文. All rights reserved.
//

#import "ViewController.h"
#import "dsbridge.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds=self.view.bounds;
    //bounds.origin.y=20;
    //bounds.size.height-=20;
    DWebview * webview=[[DWebview alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height-25)];
    webview.backgroundColor=UIColor.redColor;
    jsApi=[[JsApiTest alloc] init];
    webview.JavascriptInterfaceObject=jsApi;
    [self.view addSubview:webview];
    
    //加载test.html
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"test"
                                                          ofType:@"html"];
    NSString * htmlContent = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [webview loadHTMLString:htmlContent baseURL:baseURL];
    __weak DWebview * _webview=webview;
    [webview setJavascriptContextInitedListener:^(){
        [_webview callHandler:@"test"
                    arguments:[[NSArray alloc] initWithObjects:@1,@"hello", nil]
            completionHandler:^(NSString * value){
                NSLog(@"%@",value);
            }];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

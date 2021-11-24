//
//  ViewController.h
//  jsbridgedemo
//
//  Created by 杜文 on 17/1/1.
//  Copyright © 2017年 杜文. All rights reserved.
//

#import "JsApiTest.h"
#import "dsbridge.h"
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <WKNavigationDelegate> {
    JsApiTest *jsApi;
}

@end

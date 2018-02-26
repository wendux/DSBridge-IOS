//
//  ViewController.h
//  jsbridgedemo
//
//  Created by 杜文 on 17/1/1.
//  Copyright © 2017年 杜文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dsbridge.h"
#import "JsApiTest.h"

@interface ViewController : UIViewController <WKNavigationDelegate>
{
    JsApiTest *jsApi;
}
@end


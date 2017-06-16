# DSBridge-v2.0

[![](https://img.shields.io/cocoapods/v/dsBridge.svg?style=flat)](https://jitpack.io/#wendux/DSBridge-Android)   [![MIT Licence](https://img.shields.io/packagist/l/doctrine/orm.svg)](https://opensource.org/licenses/mit-license.php)

> DSBridge is currently the best Javascript bridge in the world , by which we can call functions synchronously and asynchronously between web and Native . Moreover, both android and ios are supported !

DSBridge-IOS:https://github.com/wendux/DSBridge-IOS

DSBridge-Android:https://github.com/wendux/DSBridge-Android

2.0更新列表：https://juejin.im/post/593fa055128fe1006aff700a

## Download

```objective-c
pod "dsBridge"
```

## Usage

1. Implement API delegate class  in Object-C

   ```objective-c
   //JsApiTest.m 
   @implementation JsApiTest
   //for synchronous invocation  
   - (NSString *) testSyn:(NSDictionary *) args
   {
       return [(NSString *)[args valueForKey:@"msg"] stringByAppendingString:@"[ syn call]"];
   }
   //for asynchronous invocation
   - (NSString *) testAsyn:(NSDictionary *) args :(void (^)(NSString * _Nullable result,BOOL isComplete))handler
   {
       handler([(NSString *)[args valueForKey:@"msg"] stringByAppendingString:@"[ asyn call]"],YES);
   }
   @end
   ```

2. Setup API  delegate class to DWebView.

   ```objective-c
   DWebview * webview=[[DWebview alloc] initWithFrame:bounds];
   jsApi=[[JsApiTest alloc] init];
   webview.JavascriptInterfaceObject=jsApi;
   ```

3. Call Object-C API in Javascript, and declare a global javascript function for the following  Object-c invocation.

   ```javascript

   //Call synchronously 
   var str=dsBridge.call("testSyn", {msg: "testSyn"});
   //Call asynchronously
   dsBridge.call("testAsyn", {msg: "testAsyn"}, function (v) {
    alert(v);
   })

   //Register javascrit function for Object-c invocation
    dsBridge.register('addValue',function(r,l){
        return r+l;
    })
   ```

4. Call Javascript function in Object-C .

   ```objective-c
    [_webview callHandler:@"addValue"
     arguments:[[NSArray alloc] initWithObjects:@1,@"hello", nil]
     completionHandler:^(NSString *  value){
         NSLog(@"%@",value);
     }];
   ```

## Javascript API introduction

### **dsBridge** 

"dsBridge" is a built-in object , it has two method "call" and "register";

### dsBridge.call(method,[args,callback])

Call Object-C api synchronously and asynchronously。

method: Object-c  method name

args: arguments with json object

callback(String returnValue):callback to handle the result. **only asynchronous invocation required**.

### dsBridge.register(methodName,function)

Register javascript method for OC invocation.

methodName: javascript function name

function: javascript method body.



## Notice

### Object-c API signature

In order to be compatible with IOS and Android, we make the following convention  on native api signature:

1. The tye of return value must be NSString;  if not need, just return nil.
2. The arguments  passed by   NSDictionary, if the API doesn't need argument, you still need declare the  argument. 

### Call javascript code

There are two methods provided by DWebView to call javascript

```objective-c
//call javascript functions
-(void)callHandler:(NSString *)methodName arguments:(NSArray * _Nullable)args 
                   completionHandler:(void (^)(NSString * _Nullable))completionHandler;
//execute any javascript code
- (void)evaluateJavaScript:(NSString *)javaScriptString 
                  completionHandler:(void (^ _Nullable)(NSString * _Nullable))completionHandler;
```



 **Opportunity of Native calling  javascript functions**

JavaScript code can only execute when the javascript context  initialization  is successful . There is a Api:

```objective-c
- (void)setJavascriptContextInitedListener:(void(^_Nullable)(void))callback;
```

example:

```objective-c
__block DWebview * _webview=webview;
[webview setJavascriptContextInitedListener:^(){
  [_webview callHandler:@"addValue"
  arguments:[[NSArray alloc] initWithObjects:@1,@"hello", nil]
  completionHandler:^(NSString *  value){
      NSLog(@"%@",value);
  }];
}];
```



### More about DWebview

There are three webviews available, DWKwebview、DUIwebview and DWebview， all of them provide the same interface, you can user any one you want.  It is worth mentioning that the  DWebview is just a proxy of DWKwebview and DUIwebview, while the ios system vesion >=8.0 ,  DWKwebview will be used, otherwise, DUIwebview will be.

### warnnig

 If you're using DUIwebview, don't set the delegate prop. because the delegate prop has been setted inner ,  please  set WebEventDelegate  instead ! 

### Alert/confirm/prompt

For alert/confirm/prompt dialog, DSBridge has implemented them all by default.

### Finally

If you like DSBridge, please star to let more people know it , Thank you  😄.

# DSBridge

> DSBridge is currently the best Javascript bridge in the world , by which we can call functions synchronously and asynchronously between web and Native . Moreover, both android and ios are supported !

DSBridge-IOS:https://github.com/wendux/DSBridge-IOS
DSBridge-Android:https://github.com/wendux/DSBridge-Android
中文文档请移步：http://www.jianshu.com/p/633d9fde946f
与WebViewJavascriptBridge的对比请移步 [DSBridge VS WebViewJavascriptBridge]( http://www.jianshu.com/p/d967b0d85b97)。

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
   - (NSString *) testAsyn:(NSDictionary *) args :(void (^)(NSString * _Nullable result))handler
   {
       handler([(NSString *)[args valueForKey:@"msg"] stringByAppendingString:@"[ asyn call]"]);
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
   //Call Object-C API
   var bridge = getJsBridge();
   //Call synchronously 
   var str=bridge.call("testSyn", {msg: "testSyn"});
   //Call asynchronously
   bridge.call("testAsyn", {msg: "testAsyn"}, function (v) {
    alert(v);
   })

   //Test will be called by Object-c, must be global function
   function test(arg1,arg2){
    return arg1+arg2;
   }
   ```

4. Call Javascript function in Object-C .

   ```objective-c
    [_webview callHandler:@"test"
     arguments:[[NSArray alloc] initWithObjects:@1,@"hello", nil]
     completionHandler:^(NSString *  value){
         NSLog(@"%@",value);
     }];
   ```

## Javascript API introduction

### **getJsBridge** 

Get the bridge object。 Although you can call it  anywhere in the page, we also advise you to call it after dom ready.

### bridge.call(method,[args,callback])

Call Object-C api synchronously and asynchronously。

method: Object-c  method name

args: arguments with json object

callback(String returnValue):callback to handle the result. **only asynchronous invocation required**.

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
  [_webview callHandler:@"test"
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

### Alert dialog

In order to prevent unnecessary obstruction, the alert dialog was implemented asynchronously , that is to say, if you call alert in javascript , it will be returned directly no matter whether the user has to deal with. becase the code flow is not subject to the user operation no matter whether user  click ok button  or close the alert dialog. if you don't need this feature, you can custom the alert dialog by override "onJsAlert" callback in WebChromeClient class.

### Finally

If you like DSBridge, please star to let more people know it , Thank you  😄.
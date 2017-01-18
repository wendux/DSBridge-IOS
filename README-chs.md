# DSBridge

> DSBridge是目前地球上最好的IOS/Android   javascript bridge. 通过它可以在web和native之间调用彼此方法。DSBridge是目前唯一一个支持同步调用的跨平台Js bridge.

DSBridge-IOS github:https://github.com/wendux/DSBridge-IOS

## 使用

1. Native 实现API 代理类

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

2. 注册api代理类至DWebview

   ```objective-c
   DWebview * webview=[[DWebview alloc] initWithFrame:bounds];
   jsApi=[[JsApiTest alloc] init];
   webview.JavascriptInterfaceObject=jsApi;
   ```

3. 在Javascript中调用Native API

   ```javascript
   //Call Native API
   var bridge = getJsBridge();
   //Call synchronously 
   var str=bridge.call("testSyn", {msg: "testSyn"});
   //Call asynchronously
   bridge.call("testAsyn", {msg: "testAsyn"}, function (v) {
    alert(v);
   })

   //Test will be called by oc， must be global function!
   function test(arg1,arg2){
    return arg1+arg2;
   }
   ```

4. 最后，Native中调用Javascript API

   ```objective-c
    [_webview callHandler:@"test"
     arguments:[[NSArray alloc] initWithObjects:@1,@"hello", nil]
     completionHandler:^(NSString *  value){
     	NSLog(@"%@",value);
     }];
   ```



## Javascript API 介绍

### getJsBridge

获取javascript bridge 对象；此方法为sdk内置，可在任何地方调用。

### bridge.call(method,[args,callback])

功能：调用Native api

method: api函数名

args:参数，类型：json, 可选参数

callback(String returnValue): 处理调用结果的回调，**仅异步调用时需要**.



## 注意

### Native API 方法签名

**为了在ios和android平台下兼容，对IOS端Native API接口约定如下：**

1. 所有API返回值类型为NSString, 不存在时返回nil即可。
2. 参数以JSON传递; DSBridge会将js参数自动转化为NSDictionary 

注：JsApiTest.m中实现的方法可以不在JsApiTest.h中声明

### 调用Javascript

DWebView提供了两个api用于调用js

```objective-c
//调用js api(函数)
-(void)callHandler:(NSString *)methodName arguments:(NSArray * _Nullable)args 
  				 completionHandler:(void (^)(NSString * _Nullable))completionHandler;
//执行任意js代码
- (void)evaluateJavaScript:(NSString *)javaScriptString 
  				completionHandler:(void (^ _Nullable)(NSString * _Nullable))completionHandler;
```

callHandler中，methodName 为js函数名，args为参数数组，可以接受数字、字符串等。

两个函数中completionHandler为完成回调，用于获取js执行的结果。

**调用时机**

DWebview只有在javascript context初始化成功后才能正确执行js代码，而javascript context初始化完成的时机一般都比整个页面加载完毕要早，随然DSBridge能捕获到javascript context初始化完成的时机，但是一些js api可能声明在页面尾部，甚至单独的js文件中，如果在javascript context刚初始化完成就调用js api, 此时js api 可能还没有加载，所以会失败，为此专门提供了一个api设置一个回调，它会在页面加载结束后调用，为了和didpagefinished区分，我们取名如下：

```objective-c
- (void)setJavascriptContextInitedListener:(void(^_Nullable)(void))callback;
```

 若是端上主动调用js，请在此回调中进行 。示例如下：

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

完整的示例请查看demo工程。


### 关于DWebview

SDK中有三个webview:

DWKwebview:继承自WKWebView，内部已经实现js prompt、alert、confirm函数对应的对话框。

DUIwebview:继承自UIWebView

DWebview:自定义view, 内部在ios8.0以下会使用DUIwebview, 大于等于8.0会使用DWKwebview。

所有的webview除了都实现了上述api之外，提供了一个加载网页的便捷函数：

```objective-c
- (void)loadUrl: (NSString *) url;
```

 **您可以根据具体业务使用任意一个**，不过一般情况下优先选用DWebview，它在新设备上更省资源，效率更高。

DWebview还提供了一些其它api和属性，具体请查看其头文件，需要特殊说明的是，有一个api：

```objective-c
- (id _Nullable) getXWebview;
```

它可以返回DWebview内部使用的真实webview, 值会是DUIwebview和DWKwebview的实例之一，您可以通过isKindOfClass来判断，吃函数主要用于扩展DWebview，下面可以看一下loadRequest的大概实现：

```objective-c
- (void)loadRequest:(NSURLRequest *)request
{
  	id webview=[self getXWebview]；
    if([webview isKindOfClass:[DUIwebview class]]){
        [(DUIwebview *)webview loadRequest:request];
    }else{
        [(DWKwebview *)webview loadRequest:request];
    }
}
```

### Alert dialog

DWebview已经实现 alert、prompt、comfirm对话框，您可以不做处理，也可以自定义。值得一提的是js 在调用alert函数正常情况下只要用户没有关闭alert对话框，js代码是会阻塞的，但是考虑到alert 对话框只有一个确定按钮，也就是说无论用户关闭还是确定都不会影响js代码流程，所以**DWebview中在弹出alert对话框时会先给js返回**，这样一来js就可以继续执行，而提示框等用户关闭时在关闭即可。如果你就是想要阻塞的alert，可以自定义。而DWebview的prompt、comfirm实现完全符合ecma标准，都是阻塞的。

请不要手动设置DUIwebview的delegate属性，因为DUIwebview在内部已经设置了该属性，如果您需要自己处理页面加载过程，请设置WebEventDelegate属性。

### 相关资料

DSBridge-Android:https://github.com/wendux/DSBridge-Android

与WebViewJavascriptBridge的对比 [DSBridge VS WebViewJavascriptBridge]( http://www.jianshu.com/p/d967b0d85b97)。

### 拉票

如果你觉得不错，麻烦star一下以便让更多人知道😄。


# DSBridge

> DSBridge是目前地球上最好的IOS/Android   javascript bridge. DSBridge有四大特点： 支持同步调用、跨平台、三端皆易用。

DSBridge-IOS:https://github.com/wendux/DSBridge-IOS

DSBridge-Android:https://github.com/wendux/DSBridge-Android

**五分钟了解DSBridge**

## Web端

假设Native端实现了两个api: testSyn、testAsyn。参数以json传递， testSyn为同步api,执行结束后会直接返回结果，而testAsyn为一个异步api(可能会执行耗时操作)，执行结束后，结果异步返回。下面我们看看web端如何调用。

### Javascript调用Native

```javascript
var bridge = getJsBridge();
var str=bridge.call("testSyn", {msg: "testSyn"});
bridge.call("testAsyn", {msg: "testAsyn"}, function (v) {
  alert(v);
})
```

简单到不用解释！太优雅了。如果你体会不来，你也许应该去看看当今（马上将会成为历史）人气最高的[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) ，相信你看完之后会回来的。

DSBridge虽说简单，但为了让你了然于胸，还是给出官方解释：

### **getJsBridge**

功能：获取javascript bridge对象。

等等，貌似和我之前使用的其他库不一样，难道不需要像WebViewJavascriptBridge那样先声明一个setupWebViewJavascriptBridge的回调？你有这种疑问很正常，先给出答案：**不需要，DSBridge不需要前端任何安装代码，随用随取**。DSBridge的设计原则就是：让三端使用方式都是最简单的！  DSBridge获取bridge时，不依赖任何回调，也无需等待页面加载结束（如果您体会不到，可以对比[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) 前端调用方式）。ps: 这在ios>=8,android>sdk19上测试都没问题，  DSBridge也对ios7.0-8.0,android sdk16-19之间的版本做了兼容，但是考虑到测试覆盖面的问题，建议所有代码都在dom ready之后执行。

### bridge.call(method,[args,callback])

功能：调用Native api

method: api函数名

args:参数，类型：json, 可选参数

callback(String returnValue):仅调用异步api时需要.

**同步调用**

如果你是一名经验丰富的开发者，想必看到第二行时已然眼睛一亮，想想node最被诟病的是什么，目前跨平台的jsbridge中没有一个能支持同步，所有需要获取值的调用都必须传一个回调，如果调用逻辑比较复杂，必将会出现“callback hell”。然而，DSBridge彻底改变了这一点。**支持同步是DSBridge的最大亮点之一**。

**异步调用**

对于一些比较耗时的api, DSBridge提供了异步支持，正如上例第三行代码所示，此时你需要传一个回调（如果没有参数，回调可作为第二个参数），当api完成时回调将会被调用，结果以字符串的形式传递。

### 供Native调用Javascript api

假设网页中要提供一个函数test供native调用，只要将函数声明为全局函数即可：

```javascript
function test(arg1,arg2){
  return arg1+arg2;
}
```

如果你的代码是在一个闭包中，将函数挂在window上即可：

```javascript
window.test=function(arg1,arg2){
  	return arg1+arg2;
}	
```

这样一来端上即可调用。

## IOS端

### 实现Api

API的实现非常简单，只需要将您要暴漏给js的api放在一个类中，然后统一注册即可。

```objective-c
//JsApiTest.m
@implementation JsApiTest
- (NSString *) testSyn:(NSDictionary *) args
{
    return [(NSString *)[args valueForKey:@"msg"] stringByAppendingString:@"[ syn call]"];
}

- (void) testAsyn:(NSDictionary *) args :(void (^)(NSString * _Nullable result))handler
{
    handler([(NSString *)[args valueForKey:@"msg"] stringByAppendingString:@"[ asyn call]"]);
}
@end
```

testSyn为同步api, js在调用同步api时会等待native返回，返回后js继续往下执行。

testAsyn为异步api, 异步操作时调用handler.complete通知js，此时js中设置的回调将会被调用。

注：JsApiTest.m中实现的方法可以不在JsApiTest.h中声明

### 注册Api

```objective-c
DWebview * webview=[[DWebview alloc] initWithFrame:bounds];
jsApi=[[JsApiTest alloc] init];
webview.JavascriptInterfaceObject=jsApi;
```

DWebview是sdk中提供的，您也可以使用其它两个，这将在后文介绍。

可见对于Native来说，通过一个单独的类实现js api, 然后直接注册（而不需要像其它一些js bridge每个api都要单独注册），这样不仅非常简单，而且结构清晰。

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

### 注意

DWebview已经实现 alert、prompt、comfirm对话框，您可以不做处理，也可以自定义。值得一提的是js 在调用alert函数正常情况下只要用户没有关闭alert对话框，js代码是会阻塞的，但是考虑到alert 对话框只有一个确定按钮，也就是说无论用户关闭还是确定都不会影响js代码流程，所以**DWebview中在弹出alert对话框时会先给js返回**，这样一来js就可以继续执行，而提示框等用户关闭时在关闭即可。如果你就是想要阻塞的alert，可以自定义。而DWebview的prompt、comfirm实现完全符合ecma标准，都是阻塞的。

请不要手动设置DUIwebview的delegate属性，因为DUIwebview在内部已经设置了该属性，如果您需要自己处理页面加载过程，请设置WebEventDelegate属性。
# DSBridge

[![](https://img.shields.io/cocoapods/v/dsBridge.svg?style=flat)](https://jitpack.io/#wendux/DSBridge-Android)   [![MIT Licence](https://img.shields.io/packagist/l/doctrine/orm.svg)](https://opensource.org/licenses/mit-license.php)
> Modern cross-platform JavaScript bridge, through which you can invoke each other's functions synchronously or asynchronously between JavaScript and native applications.

### Notice

DSBridge v3.0 is a milestone. Compared with v2.0.X, we have made a lot of changes. Note that V3.0 is **incompatible** with V2.0, but v2.0 will continue to maintain. If you are a new user, use >=v3.0.

[DSBridge v3.0.0 change list](https://github.com/wendux/DSBridge-IOS/issues/25)  

## Installation

```shell
pod "dsBridge"
```

## Examples

See the `dsbridgedemo/` package. run the `app` project and to see it in action.

To use a dsBridge in your own project:

## Usage

1. Implement APIs in a class 

   ```objective-c
   @implementation JsApiTest
   //for synchronous invocation  
   - (NSString *) testSyn:(NSString *) msg
   {
       return [msg stringByAppendingString:@"[ syn call]"];
   }
   //for asynchronous invocation
   - (void) testAsyn:(NSString *) msg :(void (^)(NSString * _Nullable result,BOOL complete))completionHandler
   {
       completionHandler([msg stringByAppendingString:@" [ asyn call]"],YES);
   }
   @end 
   ```

2. add API object to DWKWebView 

   ```objective-c
   DWKWebView * dwebview=[[DWKWebView alloc] initWithFrame:bounds];
   // register api object without namespace
   [dwebview addJavascriptObject:[[JsApiTest alloc] init] namespace:nil];
   ```

3. Call Native (Java/Object-c/swift) API in Javascript, and register  javascript API 。

   - Init dsBridge

     ```javascript
     //cdn
     //<script src="https://unpkg.com/dsbridge@3.0.6/dist/dsbridge.js"> </script>
     //npm
     //npm install dsbridge@3.0.6
     var dsBridge=require("dsbridge")
     ```

   - Call Native API and register a javascript API for Native invocation

     ```javascript

     //Call synchronously 
     var str=dsBridge.call("testSyn","testSyn");

     //Call asynchronously
     dsBridge.call("testAsyn","testAsyn", function (v) {
       alert(v);
     })

     //Register javascript API for Native
      dsBridge.register('addValue',function(l,r){
          return l+r;
      })
     ```

4. Call Javascript API in Object-C

   ```objective-c
   [dwebview callHandler:@"addValue" arguments:@[@3,@4] completionHandler:^(NSNumber* value){
           NSLog(@"%@",value);
   }];
   ```




## Object-C API signature

In order to be compatible with IOS , we make the following convention  on Object-C API signature:

1. For synchronous API.

   **`(id) handler:(id) msg`**

   The argument type can be any class  type, but  the type of return value can't be  **void**.

2. For asynchronous API.

   **` (void) handler(id arg, (void (^)( id result,BOOL complete))completionHandler）`**

   ​

## Namespace

Namespaces can help you better manage your APIs, which is very useful in   hybrid applications, because these applications have a large number of APIs. DSBridge (>= v3.0.0) allows you to classify API with namespace. And the namespace can be multilevel, between different levels with '.' division.

## Debug mode

In debug mode, some errors will be prompted by a popup dialog , and the exception caused by the native APIs will not be captured to expose problems. We recommend that the debug mode be opened at the development stage.  You can open debug mode :

```objective-c
// open debug mode
[dwebview setDebugMode:true];
```

## Javascript popup box

For Javascript popup box functions (alert/confirm/prompt), DSBridge has implemented them  all  by default. the default dialog label text language is Chinese, you can custom the text by calling `customJavascriptDialogLabelTitles`.  If you still want to implement them by yourself , set the `DSUIDelegate`  property which is a proxy of `WKUIDelegate`.



## API Reference

### Object-C API

In Object-c, the object that implements the javascript interfaces is called **Object-c API object**.

##### `addJavascriptObject:(id) object namespace:(NSString *) namespace`

Add the Object-c API object with supplied namespace into DWKWebView. The javascript can then call OC APIs  with `bridge.call("namespace.api",...)`. 

If the namespace is empty, the Object-c API object have no namespace. The javascript can  call OC APIs with `bridge.call("api",...)`. 

Example:

**In Object-c**

```objective-c
@implementation JsEchoApi
- (id) syn:(id) arg
{
    return arg;
}
- (void) asyn: (id) arg :(void (^)( id _Nullable result,BOOL complete))completionHandler
{
    completionHandler(arg,YES);
}
@end
// register api object with namespace "echo"
[dwebview addJavascriptObject:[[JsEchoApi alloc] init] namespace:@"echo"];
```

**In Javascript**

```javascript
// call echo.syn
var ret=dsBridge.call("echo.syn",{msg:" I am echoSyn call", tag:1})
alert(JSON.stringify(ret))  
// call echo.asyn
dsBridge.call("echo.asyn",{msg:" I am echoAsyn call",tag:2},function (ret) {
      alert(JSON.stringify(ret));
})
```



##### `removeJavascriptObject:(NSString *) namespace`

Remove the  Java API object with supplied namespace.



##### `callHandler:(NSString *) methodName  arguments:(NSArray *) args`

##### `callHandler:(NSString *) methodName  completionHandler:(void (^)(id value))completionHandler`

##### `callHandler:(NSString *) methodName  arguments:(NSArray *) args completionHandler:(void (^ )(id value))completionHandler`

Call the javascript API. If a `completionHandler` is given, the javascript handler can respond. the `methodName` can contain the namespace.  **The completionHandler will be called in main thread**.

Example:

```objective-c
[dwebview callHandler:@"append" arguments:@[@"I",@"love",@"you"]
  completionHandler:^(NSString * _Nullable value) {
       NSLog(@"call succeed, append string is: %@",value);
}];
// call with namespace 'syn', More details to see the Demo project                    
[dwebview callHandler:@"syn.getInfo" completionHandler:^(NSDictionary * _Nullable value) {
        NSLog(@"Namespace syn.getInfo: %@",value);
}];
```



##### `disableJavascriptDialogBlock:(bool) disable`

BE CAREFUL to use. if you call any of the javascript popup box functions (`alert`,` confirm`, and `prompt`), the app will hang, and the javascript execution flow will be blocked. if you don't want to block the javascript execution flow, call this method, the  popup box functions will return  immediately(  `confirm` return `true`, and the `prompt` return empty string).

Example:

```objective-c
[dwebview disableJavascriptDialogBlock: true]
```

if you want to  enable the block,  just calling this method with the argument value `false` .



##### `setJavascriptCloseWindowListener:(void(^_Nullable)(void))callback`

DWKWebView calls `callback` when Javascript calls `window.close`, you can provide a block to add your hanlder .

Example:

```objective-c
[dwebview setJavascriptCloseWindowListener:^{
        NSLog(@"window.close called");
}];
```



##### `hasJavascriptMethod:(NSString*) handlerName methodExistCallback:(void(^)(bool exist))callback`

Test whether the handler exist in javascript. 

Example:

```objective-c
// test if javascript method exists.
[dwebview hasJavascriptMethod:@"addValue" methodExistCallback:^(bool exist) {
      NSLog(@"method 'addValue' exist : %d",exist);
}];
```



##### `setDebugMode:(bool) debug`

Set debug mode. if in debug mode, some errors will be prompted by a popup dialog , and the exception caused by the native APIs will not be captured to expose problems. We recommend that the debug mode be opened at the development stage. 



##### `customJavascriptDialogLabelTitles:(NSDictionary*) dic`

custom the  label text of  javascript dialog that includes alert/confirm/prompt, the default text language is Chinese.

Example:

```objective-c
[dwebview customJavascriptDialogLabelTitles:@{
 @"alertTitle":@"Notification",
 @"alertBtn":@"OK",
 @"confirmTitle":@"",
 @"confirmCancelBtn":@"CANCEL",
 @"confirmOkBtn":@"OK",
 @"promptCancelBtn":@"CANCEL",
 @"promptOkBtn":@"OK"
}];
```



### Javascript API

##### dsBridge 

"dsBridge" is accessed after dsBridge Initialization .



##### `dsBridge.call(method,[arg,callback])`

Call Java api synchronously and asynchronously。

`method`: Java API name， can contain the namespace。

`arg`: argument, Only one  allowed,  if you expect multiple  parameters,  you can pass them with a json object.

`callback(String returnValue)`: callback to handle the result. **only asynchronous invocation required**.



##### `dsBridge.register(methodName|namespace,function|synApiObject)`

##### `dsBridge.registerAsyn(methodName|namespace,function|asyApiObject)`

Register javascript synchronous and asynchronous  API for Native invocation. There are two types of invocation

1. Just register a method. For example:

   In Javascript

   ```javascript
   dsBridge.register('addValue',function(l,r){
        return l+r;
   })
   dsBridge.registerAsyn('append',function(arg1,arg2,arg3,responseCallback){
        responseCallback(arg1+" "+arg2+" "+arg3);
   })
   ```

   In Object-c

   ```objective-c
   // call javascript method
   [dwebview callHandler:@"addValue" arguments:@[@3,@4] completionHandler:^(NSNumber * value){
         NSLog(@"%@",value);
   }];

   [dwebview callHandler:@"append" arguments:@[@"I",@"love",@"you"] completionHandler:^(NSString * _Nullable value) {
        NSLog(@"call succeed, append string is: %@",value);
   }];
   ```

   ​

2. Register a Javascript API object with supplied namespace. For example:

   **In Javascript**

   ```java
   //namespace test for synchronous
   dsBridge.register("test",{
     tag:"test",
     test1:function(){
   	return this.tag+"1"
     },
     test2:function(){
   	return this.tag+"2"
     }
   })
     
   //namespace test1 for asynchronous calls  
   dsBridge.registerAsyn("test1",{
     tag:"test1",
     test1:function(responseCallback){
   	return responseCallback(this.tag+"1")
     },
     test2:function(responseCallback){
   	return responseCallback(this.tag+"2")
     }
   })
   ```

   > Because JavaScript does not support function overloading, it is not possible to define asynchronous function and sync function of the same name。
   >

   **In Object-c**

   ```objective-c
   [dwebview callHandler:@"test.test1" completionHandler:^(NSString * _Nullable value) {
           NSLog(@"Namespace test.test1: %@",value);
   }];

   [dwebview callHandler:@"test1.test1" completionHandler:^(NSString * _Nullable value) {
           NSLog(@"Namespace test1.test1: %@",value);
   }];
   ```




##### `dsBridge.hasNativeMethod(handlerName,[type])`

Test whether the handler exist in Java, the `handlerName` can contain the namespace. 

`type`: optional`["all"|"syn"|"asyn" ]`, default is "all".

```javascript
dsBridge.hasNativeMethod('testAsyn') 
//test namespace method
dsBridge.hasNativeMethod('test.testAsyn')
// test if exist a asynchronous function that named "testSyn"
dsBridge.hasNativeMethod('testSyn','asyn') //false
```



##### `dsBridge.disableJavascriptDialogBlock(disable)`

Calling `dsBridge.disableJavascriptDialogBlock(...)` has the same effect as calling ` disableJavascriptDialogBlock` in Java.

Example:

```javascript
//disable
dsBridge.disableJavascriptDialogBlock()
//enable
dsBridge.disableJavascriptDialogBlock(false)
```



## Work with fly.js

As we all know, In  browser, AJax request are restricted by same-origin policy, so the request cannot be initiated across the domain.  However,    [Fly.js](https://github.com/wendux/fly) supports forwarding the http request  to Native through any Javascript bridge, And fly.js has already provide the dsBridge adapter.Because the  Native side has no the same-origin policy restriction, fly.js can request any resource from any domain. 

Another typical scene is in the hybrid App, [Fly.js](https://github.com/wendux/fly)  will forward all requests to Native, then, the unified request management, cookie management, certificate verification, request filtering and so on are carried out on Native. 

More details please refer to https://github.com/wendux/fly.

## Finally

If you like DSBridge, please star to let more people know it , Thank you !



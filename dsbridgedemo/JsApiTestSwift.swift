//
//  JsApiTestSwift.swift
//  dsbridgedemo
//
//  Created by du on 2018/9/7.
//  Copyright © 2018年 杜文. All rights reserved.
//

import Foundation
typealias JSCallback = (String, Bool)->Void

class JsApiTestSwift: NSObject {
    
    //MUST use "_" to ignore the first argument name explicitly。
    @objc func testSyn( _ arg:String) -> String {
        return String(format:"%@[Swift sync call:%@]", arg, "test")
    }
    
    @objc func testAsyn( _ arg:String, handler: JSCallback) {
        handler(String(format:"%@[Swift async call:%@]", arg, "test"), true)
    }
    
}

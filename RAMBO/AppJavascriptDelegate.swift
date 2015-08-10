//
//  AppJavascriptDelegate.swift
//  RAMBO
//
//  Created by Scott Samia on 7/20/15.
//  Copyright (c) 2015 Scott Samia. All rights reserved.
//

import Foundation
import UIKit

class AppJavascriptDelegate: NSObject, JavascriptObjectDelegate {
    var webView: UIWebView?
    var foos: Dictionary<String, (callback: String, data :String)->() >?
    
    init(wv: UIWebView) {
        super.init()
        
        webView = wv
        foos = [
            "ping": { (callback: String, data: String) in
                self.js_callback_helper(callback, data: "pong")
            },
            "vendorID": { (callback: String, data: String) in
                self.js_callback_helper(callback, data: UIDevice.currentDevice().identifierForVendor.UUIDString)
            }
        ]
    }
    
    // make sure data(string) contains no ' " ' (quote)
    func js_callback_helper(callback: String, data: String) {
        var exec: String = callback + "('" + data + "')"
        NSLog("JS: " + exec)
        self.webView!.stringByEvaluatingJavaScriptFromString(exec)
    }
    
    func call(action: String, callback: String, data: String) {
        if foos![action] != nil {
            foos![action]! (callback: callback, data: data)
        } else {
            println("Invalid action: " + action);
        }
    }
}
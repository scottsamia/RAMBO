//
//  WebViewDelegate.swift
//  RAMBO
//
//  Created by Scott Samia on 7/20/15.
//  Copyright (c) 2015 Scott Samia. All rights reserved.
//

import Foundation
import UIKit

protocol JavascriptObjectDelegate {
    func call( action: String, callback: String, data: String )
}

class WebViewDelegate: NSObject, UIWebViewDelegate {
    
    /**
    *  set window.location to string with a blank will not toggle the following function
    */
    var jod: JavascriptObjectDelegate?
    
    init(delegate: JavascriptObjectDelegate) {
        jod = delegate
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        NSLog("Processing javascript call")
        
        let js_prefix: String = "js://"
        let js_prefix_len: Int = count(js_prefix)
        
        do {
            // get url string
            let url_string: String? = request.URL!.absoluteString
            if url_string == nil { break }
            
            // test if a prefix exists
            if !url_string!.hasPrefix(js_prefix) { break }
            let request_string: String = url_string!.substringFromIndex(advance(url_string!.startIndex, js_prefix_len)) as String!
            
            var requests:Array<String> = request_string.componentsSeparatedByString("$");
            if requests.count != 3 { break }
            
            for var i=0; i<requests.count; i++ {
                requests[i] = requests[i].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            }
            
            jod!.call(requests[0], callback: requests[1], data: requests[2])
            
            return false
            
        } while false
        
        return true
    }
    
}


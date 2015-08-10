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
    *  set window.location to string with a blank will not troggle the following function
    */
    var jod: JavascriptObjectDelegate?
    var aI: UIActivityIndicatorView?
    var refresh: UIRefreshControl?
    
    init(delegate: JavascriptObjectDelegate, activityIndicator: UIActivityIndicatorView, refreshControl: UIRefreshControl) {
        jod = delegate
        aI = activityIndicator
        refresh = refreshControl
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
    
    func webViewDidStartLoad(webView: UIWebView) {
        NSLog("Web View Started Loading")
        if(!aI!.isAnimating() && !refresh!.refreshing) {
            aI!.startAnimating()
        }
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        NSLog("Web View Finished Loading")
        if(aI!.isAnimating()) {
            aI!.stopAnimating()
        }
        refresh!.endRefreshing()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        NSLog(error.description)
    }
    
}

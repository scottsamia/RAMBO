//
//  MyURLProtocol.swift
//  RAMBO
//
//  Created by Scott Samia on 7/14/15.
//  Copyright (c) 2015 Scott Samia. All rights reserved.
//

import UIKit

var requestCount = 0

class MyURLProtocol: NSURLProtocol {
    
    var connection: NSURLConnection!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        NSLog("Request #\(requestCount++): URL = \(request.URL!.absoluteString)")
        
        if NSURLProtocol.propertyForKey("MyURLProtocolHandledKey", inRequest: request) != nil {
            return false
        }
        
        return true
    }
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest,
        toRequest bRequest: NSURLRequest) -> Bool {
            return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    override func startLoading() {
        var newRequest = self.request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "MyURLProtocolHandledKey", inRequest: newRequest)
        
        self.connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.client!.URLProtocol(self, didLoadData: data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.client!.URLProtocolDidFinishLoading(self)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.client!.URLProtocol(self, didFailWithError: error)
    }
    
    func connection(connection: NSURLConnection,
        willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
            
            NSLog("WillSendAuthChallenge")
            challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
    }
}

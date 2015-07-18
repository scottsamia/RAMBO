//
//  ViewController.swift
//  RAMBO
//
//  Created by Scott Samia on 6/22/15.
//  Copyright (c) 2015 Scott Samia. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate, NSURLConnectionDelegate, DTDeviceDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTxb: UITextField!
    @IBOutlet weak var msgDisplay: UILabel!
    var lastURL: String = ""
    var refreshControl:UIRefreshControl!
    let scanner: DTDevices = DTDevices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        webView.delegate = self
        scanner.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.webView.scrollView.addSubview(refreshControl)
        self.webView.scrollView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        self.webView.scrollView.backgroundColor = UIColor.clearColor()
        self.webView.backgroundColor = UIColor.clearColor()

        lastURL = "https://rambo.rogers-corp.com"
        
        var url = NSURL(string: lastURL)
        var request = NSURLRequest(URL:url!)
        
   
        webView.loadRequest(request)
        
        println("Web View created")
        scanner.connect()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(webView: UIWebView) {
        println("Web View Started Loading")
        activityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        println("Web View Finished Loading")
        activityIndicator.stopAnimating()
    }
    
    func barcodeData(barcode: String!, type: Int32) {
        msgDisplay.text = barcode + " (" + type.description + ")"
        let script = "adaptiscanBarcode('" + barcode + "','" + type.description + "')"
        if let returnedString = webView.stringByEvaluatingJavaScriptFromString(script) {
            msgDisplay.text = msgDisplay.text! + " Sent to RAMBO"
        }

    }
    
    func deviceButtonPressed(which: Int32) {
        msgDisplay.text = "Button " + which.description + " Press"
        
                switch UInt32(scanner.connstate) {
                case CONN_CONNECTED.value:
                    msgDisplay.text = "Connected"
                case CONN_CONNECTING.value:
                    msgDisplay.text = "Connecting"
                case CONN_DISCONNECTED.value:
                    msgDisplay.text = "Disconnected"
                default:
                    msgDisplay.text = ""
                }
    }
    
    func refresh(sender:UIRefreshControl)
    {
            webView.reload()
            sender.endRefreshing()
    }
    

    @IBAction func scanButtonUp(sender: AnyObject) {
        scanner.barcodeStartScan(nil)
    }
    @IBAction func scanButtonDown(sender: AnyObject) {
        scanner.barcodeStopScan(nil)
    }
    
}


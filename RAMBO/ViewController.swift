//
//  ViewController.swift
//  RAMBO
//
//  Created by Scott Samia on 6/22/15.
//  Copyright (c) 2015 Scott Samia. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, UIWebViewDelegate, NSURLConnectionDelegate, DTDeviceDelegate, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var webView          : UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTxb       : UITextField!
    @IBOutlet weak var msgDisplay       : UILabel!
    @IBOutlet weak var configureBtn     : UIButton!
    
    var appJavascriptDelegate: AppJavascriptDelegate?
    var webViewDelegate: WebViewDelegate?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var lastURL: String = ""
    var refreshControl:UIRefreshControl!
    let scanner: DTDevices = DTDevices()
    
    let session         : AVCaptureSession = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    //var highlightView   : UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //webView.delegate = self
        scanner.delegate = self
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.webView.scrollView.addSubview(refreshControl)
        self.webView.scrollView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        self.webView.scrollView.backgroundColor = UIColor.clearColor()
        self.webView.backgroundColor = UIColor.clearColor()
        
        appJavascriptDelegate = AppJavascriptDelegate(wv: webView!)
        webViewDelegate = WebViewDelegate(delegate: appJavascriptDelegate!, activityIndicator: activityIndicator!, refreshControl: refreshControl!)
        webView.delegate = webViewDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsChanged",
            name: NSUserDefaultsDidChangeNotification, object: nil)

        loadSite()
        
        NSLog("Web View created")
        scanner.connect()
        initCamera()
        
    }
    
    override func loadView() {
        super.loadView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barcodeData(barcode: String!, type: Int32) {
        msgDisplay.text = barcode + " (" + type.description + ")"
        var callback_pref: String = userDefaults.stringForKey("callback_preference")!
        if !callback_pref.isEmpty {
            configureBtn.hidden = true
            //adaptiscanBarcode
            let script = callback_pref + "('" + barcode + "','" + type.description + "')"
            if let returnedString = webView.stringByEvaluatingJavaScriptFromString(script) {
                msgDisplay.text = msgDisplay.text! + " Sent to RAMBO"
            }
        }
        else {
            configureBtn.hidden = false
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
        if(!activityIndicator.isAnimating()) {
            self.webView.reload()
        }
        else {
            refreshControl!.endRefreshing()
        }
    }
    
    func defaultsChanged() {
        loadSite()
    }
    
    func loadSite() {
        var url_pref: String = ""
        if(userDefaults.objectForKey("url_preference") != nil) {
            url_pref = userDefaults.stringForKey("url_preference")!
        }
        
        var callback_pref: String = ""
        if(userDefaults.objectForKey("callback_preference") != nil) {
            callback_pref = userDefaults.stringForKey("callback_preference")!
        }
        
        if !url_pref.isEmpty && !callback_pref.isEmpty {
            configureBtn.hidden = true
            
            let ssl_pref: Bool = userDefaults.boolForKey("ssl_preference")
            if (url_pref.lowercaseString.rangeOfString("http") != nil){
                if ssl_pref {
                    url_pref = url_pref.stringByReplacingOccurrencesOfString("http://", withString: "https://", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                else {
                    url_pref = url_pref.stringByReplacingOccurrencesOfString("https://", withString: "http://", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
            }
            else {
                if ssl_pref {
                    url_pref = "https://" + url_pref
                }
                else {
                    url_pref = "http://" + url_pref
                }
            }
            
            lastURL = url_pref
            var url = NSURL(string: lastURL)
            var request = NSURLRequest(URL:url!)
            
            
            webView.loadRequest(request)
        }
        else {
            configureBtn.hidden = false
        }
        
    }
    

    @IBAction func scanButtonUp(sender: AnyObject) {
        //scanner.barcodeStopScan(nil)
    }
    @IBAction func scanButtonDown(sender: AnyObject) {
        //scanner.barcodeStartScan(nil)
        startCameraScan()
        
    }
    
    @IBAction func handleTakeMeButtonPressed(sender: AnyObject) {
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func startCameraScan() {
        self.view.layer.addSublayer(previewLayer)
        session.startRunning()
        NSLog("SCANNER IS RUNNING")
    }
    
    func initCamera() {
        
//        // Allow the view to resize freely
//        self.highlightView.autoresizingMask =   UIViewAutoresizing.FlexibleTopMargin |
//            UIViewAutoresizing.FlexibleBottomMargin |
//            UIViewAutoresizing.FlexibleLeftMargin |
//            UIViewAutoresizing.FlexibleRightMargin
//        
//        // Select the color you want for the completed scan reticle
//        self.highlightView.layer.borderColor = UIColor.greenColor().CGColor
//        self.highlightView.layer.borderWidth = 3
//        
//        // Add it to our controller's view as a subview.
//        self.view.addSubview(self.highlightView)
        
        
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the "var" keyword and not "let"
        var error : NSError? = nil
        
        
        let input : AVCaptureDeviceInput? = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
        if input != nil {
            session.addInput(input)
        }
        else {
            // This is fine for a demo, do something real with this in your app. :)
            NSLog(error!.description)
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        
        previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        
    }
    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        
        var barCodeObject : AVMetadataObject!
        
        var barcodeString : String!
        var barcodeTypeString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for theItem in metadataObjects {
            
            if let _item = theItem as? AVMetadataMachineReadableCodeObject {
                NSLog(_item.type)
                for barcodeType in barCodeTypes {
                    
                    if _item.type == barcodeType {
                        barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(_item)
                        
                        highlightViewRect = barCodeObject.bounds
                        
                        barcodeString = _item.stringValue
                        barcodeTypeString = _item.type
                        
                        self.session.stopRunning()
                        break
                    }
                    
                }
            }
        }
        if barcodeString != nil {
            NSLog(barcodeString)
            barcodeData(barcodeString, type: 128)
            previewLayer.removeFromSuperlayer()
        }
        
        //self.highlightView.frame = highlightViewRect
        //self.view.bringSubviewToFront(self.highlightView)
        
        
    }
    
}


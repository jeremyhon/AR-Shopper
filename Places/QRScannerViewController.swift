//
//  QRScannerViewController.swift
//  Places
//
//  Created by Jia Wern Yong on 22/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import AVFoundation
import UIKit

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  @IBOutlet weak var messageLabel: UILabel!
  
  var origin:ViewController?
  var captureSession:AVCaptureSession?
  var videoPreviewLayer:AVCaptureVideoPreviewLayer?
  var qrCodeFrameView:UIView?
  
  func setOrigin(vc:ViewController) {
    self.origin = vc
    print("origin set")
    print("second screen", vc.secondScreen)
  }
  
  // Added to support different barcodes
  let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Initialize the captureSession object.
      captureSession = AVCaptureSession()
      // Set the input device on the capture session.
      captureSession?.addInput(input)
      
      // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession?.addOutput(captureMetadataOutput)
      
      // Set delegate and use the default dispatch queue to execute the call back
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      
      // Detect all the supported bar code
      captureMetadataOutput.metadataObjectTypes = supportedBarCodes
      
      // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)
      
      // Start video capture
      captureSession?.startRunning()
      
      // Move the message label to the top view
      view.bringSubview(toFront: messageLabel)
      
      // Initialize QR Code Frame to highlight the QR code
      qrCodeFrameView = UIView()
      
      
      print("Checking qrCodeFrameView")
      if let qrCodeFrameView = qrCodeFrameView {
        qrCodeFrameView.frame = CGRect(x:125, y:250, width: 150, height: 150)
        print(qrCodeFrameView)
        print("Changing border color")
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        print("Changing borderwidth")
        qrCodeFrameView.layer.borderWidth = 2
        print("Adding subview")
        view.addSubview(qrCodeFrameView)
        print("Bring subview to front")
        view.bringSubview(toFront: qrCodeFrameView)
      }
      
    } catch {
      // If any error occurs, simply print it out and don't continue any more.
      print("ERROR ERROR")
      print(error)
      return
    }
    
  }
  
  func update() {
//    self.performSegue(withIdentifier: "mainSegue", sender: nil)
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! ViewController
    vc.goToSecondScreen()
    self.present(vc, animated: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    print("something detected")
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects == nil || metadataObjects.count == 0 {
      qrCodeFrameView?.frame = CGRect.zero
      messageLabel.text = "No barcode/QR code is detected"
      return
    }
    
    // Get the metadata object.
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
    // Here we use filter method to check if the type of metadataObj is supported
    // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
    // can be found in the array of supported bar codes.
    if supportedBarCodes.contains(metadataObj.type) {
      //        if metadataObj.type == AVMetadataObjectTypeQRCode {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds
      
      if metadataObj.stringValue != nil {
        messageLabel.text = metadataObj.stringValue
      }
    }
  }
}


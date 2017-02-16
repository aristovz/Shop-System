//
//  ScanerView.swift
//  Shop System
//
//  Created by Pavel Aristov on 09.02.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import Foundation
import AVFoundation

class ScanerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    var delegate: ScanerViewDelegate?
    
    func startMonitoring() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            let input: AnyObject! = try AVCaptureDeviceInput(device: captureDevice)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as! AVCaptureInput)
            
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
            videoPreviewLayer?.frame = self.layer.bounds
            self.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession!.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                self.addSubview(qrCodeFrameView)
                self.bringSubview(toFront: qrCodeFrameView)
            }
            
            // Move the message label to the top view
            for view in self.subviews {
                self.bringSubview(toFront: view)
            }
        }
        catch {
            print("\(error.localizedDescription)")
            return
        }
    }

    var lastCode: String? = nil;
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedBarCodes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil && lastCode != metadataObj.stringValue {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                lastCode = metadataObj.stringValue
                delegate?.scanerView(self, didDetectCode: metadataObj.stringValue)
            }
        }
    }
}

protocol ScanerViewDelegate {
    func scanerView(_ scanerView: ScanerView, didDetectCode code: String)
}

//
//  ScanerController.swift
//  Shop System
//
//  Created by Pavel Aristov on 07.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//


import AVFoundation
import UIKit
import AudioToolbox
import SwiftyJSON

class ScanerController: UIViewController, ScanerViewDelegate {
    
//    @IBOutlet weak var messageButton: UIButton!
//    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var controlPanelView: UIView!
  
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var codeView: ScanerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var codes = [String]()
    var currentChannel: JSON? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = currentChannel!["name"].stringValue
        codes = currentChannel!["codes"].stringValue.components(separatedBy: ",")
        
        codeView.delegate = self
        codeView.startMonitoring()
    }
    
    func scanerView(_ scanerView: ScanerView, didDetectCode code: String) {
        if !codes.contains(code) {
            self.codes.insert(code, at: 0)
            
            activityView.isHidden = false
            activityIndicator.startAnimating()
            
            API.TransactionsManager.addCode(id: currentChannel!["id"].intValue, code: code) { (result) in
                if result != nil && result! {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    
                    self.activityView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                else {
                    self.activityView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        API.TransactionsManager.endMonitoring(id: currentChannel!["id"].intValue) { (result) in
            if result {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func flashButton(_ sender: UIButton) {
        let avDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)!
        
        // check if the device has torch
        if avDevice.hasTorch {
            // lock your device for configuration
            do {
                try avDevice.lockForConfiguration()
            } catch {
                print("error for lock")
            }
            
            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if avDevice.isTorchActive {
                avDevice.torchMode = AVCaptureTorchMode.off
            } else {
                // sets the torch intensity to 100%
                do {
                    try avDevice.setTorchModeOnWithLevel(1.0)
                } catch {
                    print("error for on flashlight")
                }
            }
            // unlock your device
            avDevice.unlockForConfiguration()
        }
    }
}

extension ScanerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.codes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "codeCell")
        
        cell?.textLabel?.text = codes[indexPath.row]
        
        return cell!
    }
}

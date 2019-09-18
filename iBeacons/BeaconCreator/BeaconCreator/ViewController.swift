//
//  ViewController.swift
//  BeaconCreator
//
//  Created by Peyman on 8/26/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    /// UUID Label
    @IBOutlet weak var uuidLabel: UILabel!
    /// Device Name Label
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    /// Bluetooth CLass
    var bleManager: AppBLEManager!
    
    @IBAction func startRegion(_ sender: UIButton) {
        guard let beaconClass = bleManager else {
            return
        }
        beaconClass.startBeaconSpreading(success: { (success) in
            self.deviceNameLabel.text = "Beacon is transmitting"
            print("Success")
        }) { (error) in
            print("Error: \(error.localizedDescription)")
            self.deviceNameLabel.text = nil
        }
    }
    
    @IBAction func stopRegion(_ sender: UIButton) {
        guard let beaconClass = bleManager else {
            return
        }
        beaconClass.stopLocalBeacon()
        self.deviceNameLabel.text = "Beacon not transmitting"
    }
    
}

//MARK:- View Life Cycles
extension ViewController {
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bleManager = AppBLEManager()
        bleManager.delegate = self
    }
}

extension ViewController: AppBLEManagerDelegate {
    func bluetoothStateIssue(Error error: Error) {
        
    }
    
    func beaconStartedToTransmit() {
        self.deviceNameLabel.text = "Beacon is transmitting"
    }
    
}

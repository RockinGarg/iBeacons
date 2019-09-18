//
//  ViewController.swift
//  BeaconDetector
//
//  Created by Peyman on 8/26/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var baconDetectionStatsLabel: UILabel!
    var bleManger: AppBLEManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bleManger = AppBLEManager()
        bleManger.delegate = self
    }

    @IBAction func startScanning(_ sender: Any) {
        bleManger.initLocationManager()
    }
    
    @IBAction func stopScanning(_ sender: Any) {
        bleManger.stopScanning()
    }
    
}

extension ViewController: AppBLEManagerProtocol {
    func beaconIssueDetected(Error error: LOCErrors) {
        switch error {
        case .locationAccessMissing(let msg):
            self.showAlertWithAction(Title: "BLE Beacon App", Message: msg, ButtonTitle: "Settings") { (action) in
                /// Navigate to app setting
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
        case .locationServiceDisabled(let msg):
            self.showAlertWithAction(Title: "BLE Beacon App", Message: msg, ButtonTitle: "Ok") { (action) in
                
            }
        default:
            self.showAlert(Title: "BLE Beacon App", Message: error.errorDescription ?? "")
        }
    }
    
    func beaconRegionStatusDetect(Status status: BeaconRegDistStatus) {
        baconDetectionStatsLabel.text = status.description
    }
    
    func scanRewardsterCard() {
        self.showAlert(Title: "BLE Beacon App", Message: "Card Scanned")
    }
}

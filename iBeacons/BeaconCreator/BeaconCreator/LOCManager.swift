//
//  LOCManager.swift
//  BeaconCreator
//
//  Created by Peyman on 8/26/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

let deviceUUID: String = "F7826DA6-4FA2-4E98-8024-BC5B71E8899E"
let regionName: String = "RewardsterBeacon"

//MARK:- My Error
enum LOCErrors: Error {
    /// Bluetooth Power Issue
    case bluetoothIssue(String)
}

//MARK: MyError Extension
extension LOCErrors: LocalizedError {
    /// Localised Description
    public var errorDescription: String? {
        switch self {
        case .bluetoothIssue(let msg):
            return NSLocalizedString(msg, comment: "")
        }
    }
}

protocol AppBLEManagerDelegate {
    func bluetoothStateIssue(Error error: Error)
    func beaconStartedToTransmit()
}

class AppBLEManager: NSObject {
    /// Location Manager Shared Object
    @objc static let shared = AppBLEManager()
    
    /// Location Manager - Used to get location
    var locationManager = CLLocationManager()
    var delegate: AppBLEManagerDelegate?
    
    var beaconToMonitor: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
}

//MARK:- Required Functions
extension AppBLEManager {
    //MARK: Start Beacon
    func startBeaconSpreading(success: @escaping(Bool) -> Void, failed: @escaping(Error) -> Void) {
        beaconToMonitor = createABeaconRegion()
        beaconPeripheralData = beaconToMonitor.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    //MARK: Create a Beacon Region
    func createABeaconRegion() -> CLBeaconRegion {
        let beacon = CLBeaconRegion(proximityUUID: UUID(uuidString: deviceUUID)!, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: regionName)
        return beacon
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        beaconToMonitor = nil
    }
}

extension AppBLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Starting to Advertise Beacon Region")
            self.delegate?.beaconStartedToTransmit()
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
            self.delegate?.bluetoothStateIssue(Error: LOCErrors.bluetoothIssue("Bluetooth Poered Off."))
        }
    }
}

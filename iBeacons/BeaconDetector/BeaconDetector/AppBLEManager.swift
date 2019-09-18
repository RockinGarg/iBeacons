//
//  AppBLEManager.swift
//  BeaconDetector
//
//  Created by Peyman on 8/26/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit
import CoreLocation

//MARK:- My Error
enum LOCErrors: Error {
    //// Logout User
    case locationServiceDisabled(String)
    /// No Access Granted
    case locationAccessMissing(String)
    /// Monitoring Region not allowed
    case monitoringBeaconUnavialble(String)
    /// Monitoring Region Range Issue
    case monitoringRegionRangeIssue(String)
}

//MARK: MyError Extension
extension LOCErrors: LocalizedError {
    /// Localised Description
    public var errorDescription: String? {
        switch self {
        case .locationServiceDisabled(let msg):
            return NSLocalizedString(msg, comment: "")
        case .locationAccessMissing(let msg):
            return NSLocalizedString(msg, comment: "")
        case .monitoringBeaconUnavialble(let msg):
            return NSLocalizedString(msg, comment: "")
        case .monitoringRegionRangeIssue(let msg):
            return NSLocalizedString(msg, comment: "")
        }
    }
}

enum BeaconRegDistStatus: String {
    case far = "Far"
    case near = "Near"
    case immediate = "Immediate"
    case entered = "Entered Region"
    case exit = "Exited Region"
    case unknown = "Unknown State"
    case stopScan = "Scan Stopped"
    case noBeacon = "Beacon not detected"
    
    /// String Description Added
    var description : String {
        get {
            return self.rawValue
        }
    }
}

protocol AppBLEManagerProtocol {
    func beaconIssueDetected(Error error: LOCErrors)
    func beaconRegionStatusDetect(Status status: BeaconRegDistStatus)
    func scanRewardsterCard()
}

let deviceUUID: String = "F7826DA6-4FA2-4E98-8024-BC5B71E8899E"
let regionName: String = "RewardsterBeacon"

class AppBLEManager: NSObject {
    var locationManager: CLLocationManager!
    var beaconRegionToMonitor: CLBeaconRegion!
    var delegate: AppBLEManagerProtocol?
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: deviceUUID)!
        beaconRegionToMonitor = CLBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: regionName)
        beaconRegionToMonitor.notifyEntryStateOnDisplay = true
        beaconRegionToMonitor.notifyOnEntry = true
        beaconRegionToMonitor.notifyOnExit = true
        locationManager.startMonitoring(for: beaconRegionToMonitor)
        locationManager.startRangingBeacons(in: beaconRegionToMonitor)
    }
    
    func stopScanning() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoring(for: beaconRegionToMonitor)
        locationManager.stopRangingBeacons(in: beaconRegionToMonitor)
        self.delegate?.beaconRegionStatusDetect(Status: .stopScan)
    }
}

extension AppBLEManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                } else {
                    print("Range issue")
                    self.delegate?.beaconIssueDetected(Error: .monitoringRegionRangeIssue("Range monitor issue"))
                }
            } else {
                print("Minitoring issue")
                self.delegate?.beaconIssueDetected(Error: .monitoringBeaconUnavialble("Beacon monitoring unavailable."))
            }
        } else {
            print("Access issue")
            self.delegate?.beaconIssueDetected(Error: .locationAccessMissing("Location access isn't granted."))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("The monitored regions are: \(manager.monitoredRegions)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let beaconRegion = region as! CLBeaconRegion
        print("Did enter region: " + (beaconRegion.major?.stringValue)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let beaconRegion = region as! CLBeaconRegion
        print("Did exit region: " + (beaconRegion.major?.stringValue)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if region.identifier == regionName {
            if beacons.count > 0 {
                for beacon in beacons {
                    print("UDID: \(beacon.proximityUUID.uuidString)")
                }
                print("Acuracy: \(beacons[0].accuracy)")
                if beacons[0].accuracy < CLLocationAccuracy(0.15) && beacons[0].proximity == .immediate {
                    self.delegate?.scanRewardsterCard()
                }
                updateDistance(beacons[0].proximity)
            } else {
                self.delegate?.beaconRegionStatusDetect(Status: .noBeacon)
            }
        } else {
            self.delegate?.beaconRegionStatusDetect(Status: .noBeacon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beaconRegion = region as! CLBeaconRegion
        if beaconRegion.identifier == regionName {
            switch state {
            case .inside:
                locationManager.startRangingBeacons(in: self.beaconRegionToMonitor)
                self.delegate?.beaconRegionStatusDetect(Status: .entered)
            case .outside:
                print("Outside")
                self.delegate?.beaconRegionStatusDetect(Status: .exit)
            default:
                print("Unknown state")
                self.delegate?.beaconRegionStatusDetect(Status: .noBeacon)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error failed monitoring: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Loc manager failed: \(error.localizedDescription)")
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                print("Far")
                self.delegate?.beaconRegionStatusDetect(Status: .far)
            case .near:
                print("Near")
                self.delegate?.beaconRegionStatusDetect(Status: .near)
            case .immediate:
                print("Immediate")
                self.delegate?.beaconRegionStatusDetect(Status: .immediate)
            default:
                print("Unknown")
                self.delegate?.beaconRegionStatusDetect(Status: .noBeacon)
            }
        }
    }
}

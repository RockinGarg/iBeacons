//
//  UIViewController+Ext.swift
//  BeaconDetector
//
//  Created by Peyman on 8/26/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(Title title: String, Message message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction(Title title: String, Message message: String, ButtonTitle bTitle: String, ButtonPress: @escaping(Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: bTitle, style: .default, handler: { (action) in
            ButtonPress(true)
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

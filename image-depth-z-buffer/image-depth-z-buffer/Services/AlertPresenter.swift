//
//  AlertPresenter.swift
//  SwiftCoreTraining
//
//  Created by Serg Liamthev on 3/23/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit

class AlertPresenter {
    
    static func showError(at vc: UIViewController, error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showSuccessMessage(at vc: UIViewController, message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
}

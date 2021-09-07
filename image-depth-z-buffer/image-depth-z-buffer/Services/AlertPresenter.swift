//
//  AlertPresenter.swift
//  SwiftCoreTraining
//
//  Created by Serg Liamthev on 3/23/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit

final class AlertPresenter {
    
    static func showError(at vc: UIViewController, error: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { _ in }
            alert.addAction(action)
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showSuccessMessage(at vc: UIViewController, message: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { _ in }
            alert.addAction(action)
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
}

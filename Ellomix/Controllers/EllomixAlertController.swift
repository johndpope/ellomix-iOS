//
//  File.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/18/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class EllomixAlertController {
    
    static func showAlert(viewController: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> ())? = nil, completion: (() -> ())? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        viewController.present(alert, animated: true, completion: completion)
    }
    
    static func showActionSheet(viewController: UIViewController, actions: [UIAlertAction], handler: ((UIAlertAction) -> ())? = nil, completion: (() -> ())? = nil) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for action in actions {
            alert.addAction(action)
        }
        
        viewController.present(alert, animated: true, completion: completion)
    }
}

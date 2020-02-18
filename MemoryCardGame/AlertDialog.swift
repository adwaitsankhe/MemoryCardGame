//
//  AlertDialog.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/18/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import UIKit

class AlertDialog {
    private var title: String
    private var message: String
    private var presentingVC: UIViewController
    private var primaryButtonAction: UIAlertAction
    private var secondaryButtonAction: UIAlertAction?

    init(title: String,
         message: String,
         presentingVC: UIViewController,
         primaryButtonAction: UIAlertAction,
         secondaryButtonAction: UIAlertAction? = nil) {
        self.title = title
        self.message = message
        self.presentingVC = presentingVC
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
    }

    func presentAlert() {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(primaryButtonAction)

        if let secondaryButtonAction = secondaryButtonAction {
            alert.addAction(secondaryButtonAction)
        }

        return presentingVC.present(alert, animated: true, completion: nil)
    }
}

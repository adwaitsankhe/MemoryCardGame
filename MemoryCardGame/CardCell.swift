//
//  CardCell.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/18/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var placeHolderView: UIImageView!
    @IBOutlet weak var actualImage: UIImageView!
    private(set) var isVisible = false
    
    var card: Card? {
        didSet {
            guard let card = self.card else { return }
            actualImage.image = card.image
            placeHolderView.image = UIImage(named: "Image")
        }
    }
    
    func show(_ visible: Bool) {
        placeHolderView.isHidden = false
        actualImage.isHidden = false
        isVisible = visible
        
        let fromImage = visible ? placeHolderView : actualImage
        let toImage = visible ? actualImage : placeHolderView
        UIView.transition(from: fromImage!, to: toImage!, duration: 0.3, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: { (done) -> () in
        })
    }
}

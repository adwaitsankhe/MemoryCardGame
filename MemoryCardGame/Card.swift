//
//  Card.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/15/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import UIKit

class Card: NSObject, NSCopying {
    private(set) var image: UIImage?
    private var id: Int
    private var isSeen: Bool
    
    init(image: UIImage, id: Int) {
        self.image = image
        self.id = id
        isSeen = false
    }
    
    init(card: Card) {
        self.image = card.image
        self.id = card.id
        self.isSeen = card.isSeen
    }
    
    func isSame(asCard card: Card) -> Bool {
        return card.id == id
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Card(card: self)
    }
}

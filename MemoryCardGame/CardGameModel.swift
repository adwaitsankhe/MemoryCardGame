//
//  CardGameModel.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/15/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import Foundation

protocol CardGameProtocol {
    func start()
    func end()
    func show(cards: [Card], forGame game: CardGameModel)
    func hide(cards: [Card], forGame game: CardGameModel)
}

class CardGameModel {
    private var cards = [Card]()
    private var visibleCards = [Card]()
    private(set) var isPlaying = false
    var delegate: CardGameProtocol?
    
    func setupGame(withCards cards: [Card]) -> [Card] {
        self.cards = cards.shuffled()
        delegate?.start()
        return self.cards
    }
    
    func startNewGame() {
        isPlaying = true
        visibleCards.removeAll()
    }
    
    func restartGame() {
        cards.removeAll()
        startNewGame()
    }
    
    func cardAt(index: Int) -> Card? {
        return cards.count > index ? cards[index] : nil
    }
    
    func endGame() {
        isPlaying = false
    }
    
    func index(forCard card: Card) -> Int? {
        for index in 0...cards.count-1 {
            if card === cards[index] {
                return index
            }
        }
        return nil
    }
    
    func didSelect(card: Card?) {
        guard let card = card else { return }
        delegate?.show(cards: [card], forGame: self)
        
        if visibleCards.count % 2 != 0 {
            if card.isSame(asCard: visibleCards.last!) {
                visibleCards.append(card)
            } else {
                let mismatchedCard = visibleCards.removeLast()
                
                let delayTime = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
                    self!.delegate?.hide(cards: [card, mismatchedCard], forGame: self!)
                }
            }
        } else {
            visibleCards.append(card)
        }
        
        if visibleCards.count == cards.count {
            delegate?.end()
        }
    }
}

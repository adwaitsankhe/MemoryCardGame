//
//  ViewController.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/15/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let edgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberOfFlipsLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    private var timer: Timer?
    private var timerCount = 0
    
    private var cards = [Card]()
    private let gameModel = CardGameModel()
    private let downloader = CardsDownloader()
    private var flipsCount = 0 {
        didSet {
            numberOfFlipsLabel.text = "Flips: \(flipsCount)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupCardImages()
        
        activityIndicator.color = .white
        collectionView.isUserInteractionEnabled = false
    }
    
    @IBAction func onStartGame(_ sender: Any) {
        collectionView.isUserInteractionEnabled = true
        playButton.setTitle("RESTART GAME", for: .normal)
        
        if gameModel.isPlaying {
            restartGameDialog()
            timer?.invalidate()
        }
        
        if !gameModel.isPlaying {
            restartGame()
            timer?.invalidate()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            print("Timer fired!")
            self?.timerCount += 1
            self?.timerLabel.text = self?.secondsToHumanReadableTime() ?? ""
        }
    }
    
    private func setupDelegates() {
        gameModel.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func secondsToHumanReadableTime() -> String {
        let secs = String(timerCount % 60).count == 1 ? "0\(timerCount % 60)" : String(timerCount % 60)
        let mins = String(timerCount / 60).count == 1 ? "0\(timerCount / 60)" : String(timerCount / 60)
        let hrs = String(timerCount / 3600).count == 1 ? "0\(timerCount / 3600)" : String(timerCount / 3600)
        
        return "\(hrs):\(mins):\(secs)"
    }
    
    private func setupCardImages() {
        if !downloader.isNetworkReachable {
            let exitAction = UIAlertAction(title: exitButtonTitle, style: .cancel) { action in
                exit(0)
            }
            
            let dialog = AlertDialog(title: notConnectedAlertTitle, message: notConnectedAlertMessage, presentingVC: self, primaryButtonAction: exitAction)
            dialog.presentAlert()
            return
        }
        
        showLoading()
        downloader.getCardImages { [weak self] cards in
            if let cards = cards {
                self?.cards = cards
                self?.setupNewGame()
                self?.stopLoading()
            }
        }
    }
    
    private func showLoading() {
        collectionView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopLoading() {
        collectionView.isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func setupNewGame() {
        cards = gameModel.setupGame(withCards: cards)
        collectionView.reloadData()
        flipsCount = 0
        timerCount = 0
    }
    
    private func restartGame() {
        gameModel.restartGame()
        setupNewGame()
    }
    
    private func restartGameDialog() {
        let cancelAction = UIAlertAction(title: noButtonTitle, style: .cancel, handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        })
        
        let playAgainAction = UIAlertAction(title: yesButtonTitle, style: .default) { [weak self] action in
            self?.restartGame()
        }
        
        let dialog = AlertDialog(title: abandonGameAlertTitle, message: abandonGameAlertMessage, presentingVC: self, primaryButtonAction: playAgainAction, secondaryButtonAction: cancelAction)
        dialog.presentAlert()
        timer?.invalidate()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell
        cell?.card = gameModel.cardAt(index: indexPath.item)
        cell?.show(false)
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCell {
            if cell.isVisible { return }
            gameModel.didSelect(card: cell.card)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension ViewController: CardGameProtocol {
    func start() {
        collectionView.reloadData()
    }
    
    func end() {
        timer?.invalidate()
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { [weak self] action in
            self?.gameModel.endGame()
            self?.dismiss(animated: true, completion: nil)
        }
        
        let playAgainAction = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            self?.setupCardImages()
            self?.setupNewGame()
            self?.gameModel.startNewGame()
        }
        
        let alert = AlertDialog(title: gameCompleteAlertTitle, message: gameCompleteAlertMessage, presentingVC: self, primaryButtonAction: playAgainAction, secondaryButtonAction: cancelAction)
        alert.presentAlert()
    }
    
    func show(cards: [Card], forGame game: CardGameModel) {
        for card in cards {
            guard let index = game.index(forCard: card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as? CardCell
            cell?.show(true)
            flipsCount += 1
        }
    }
    
    func hide(cards: [Card], forGame game: CardGameModel) {
        for card in cards {
            guard let index = game.index(forCard: card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as? CardCell
            cell?.show(false)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberofItem: CGFloat = 4
        let collectionViewWidth = collectionView.bounds.width
        let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
        let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
        let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
        return CGSize(width: width, height: width)
    }
}

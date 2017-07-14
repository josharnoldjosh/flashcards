//
//  StudyViewController.swift
//  flashcards
//
//  Created by Josh Arnold on 21/04/16.
//  Copyright © 2016 Josh Arnold. All rights reserved.
//

import UIKit

class StudyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    var collectionView:UICollectionView!
    var dict:[AnyHashable: Any]!
    var originalDict:[AnyHashable: Any]!
    var currentCardIndex:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Study"
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StudyViewController.cancel))
        
        if dict["cards"] != nil && (dict["cards"]  as! [[String:String]]).count > 0 {
            
            
            
            setupData()
            
            let flow = UICollectionViewFlowLayout()
            flow.itemSize = CGSize(width: view.frame.width, height: view.frame.height-(navigationController?.navigationBar.frame.height)!-64)
            flow.scrollDirection = .horizontal
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flow)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            collectionView.backgroundColor = UIColor.white
            collectionView.isPagingEnabled = true
            collectionView.alwaysBounceHorizontal = true
            collectionView.showsHorizontalScrollIndicator = false
            view.addSubview(collectionView)
            collectionView.scrollToItem(at: IndexPath(row:1, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
            
            if UserDefaults.standard.integer(forKey: "shuffleHint")  <= 5 {
                let shake = UILabel(frame: CGRect(x: 16, y: ((navigationController?.navigationBar.frame.height)!+32), width: view.frame.width-32, height: 16))
                shake.text = "(Shake device to shuffle cards)"
                shake.textColor = UIColor.lightGray
                shake.textAlignment = .center
                view.addSubview(shake)
                UIView.animate(withDuration: 1, delay: 10, options: UIViewAnimationOptions(), animations: {
                    shake.alpha = 0
                    }, completion: { (done) in
                        if done {
                            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "shuffleHint")+1, forKey: "shuffleHint")
                        }
                })
            }
            
            currentCardIndex = UILabel(frame: CGRect(x: 16, y: view.frame.height-24, width: view.frame.width-32, height: 16))
            currentCardIndex.textAlignment = .center
            let cards = dict["cards"] as! [[String:String]]
            currentCardIndex.text = "1 out of \(cards.count-2)"
            currentCardIndex.textColor = UIColor.lightGray
            view.addSubview(currentCardIndex)
            
        }else{
            
            let question = UILabel(frame: CGRect(x: 16, y: 16, width: view.frame.width-32, height: view.frame.height-32))
            question.textColor = UIColor(white: 0.5, alpha: 1)
            question.numberOfLines = 0
            question.textAlignment = .center
            question.font = UIFont(name: (question.font?.fontName)!, size: 25)
            question.tag = 2
            question.text = "You haven't added any cards to this deck."
            view.addSubview(question)
            
        }
        
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupData() {
        originalDict = dict
        var cards = dict["cards"] as! [[String:String]]
        cards.append(cards.first!)
        cards.insert(cards[cards.count-2], at: 0)
        dict["cards"] = cards
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dict["cards"] as! [[AnyHashable: Any]]).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.white
        
        let cards = dict["cards"] as! [[String:String]]
        let card = cards[indexPath.row]
        
        var background = cell.contentView.viewWithTag(1)
        if background == nil {
            background = UIView(frame: cell.contentView.frame.insetBy(dx: 16, dy: 16))
            background!.tag = 1
            background!.backgroundColor = UIColor(white: 0.95, alpha: 1)
            background?.layer.cornerRadius = 8
            cell.contentView.addSubview(background!)
        }
        
        var question = background!.viewWithTag(2) as? UILabel
        if question == nil {
            question = UILabel(frame: CGRect(x: 16, y: 16, width: background!.frame.width-32, height: background!.frame.height-32))
            question!.textColor = UIColor(white: 0.5, alpha: 1)
            question!.numberOfLines = 0
            question!.textAlignment = .center
            question!.font = UIFont(name: (question?.font?.fontName)!, size: 25)
            question!.tag = 2
            question!.alpha = 1
            background?.addSubview(question!)
        }
        question?.alpha = 1
        question?.text = card["question"]
        
        var answer = background!.viewWithTag(3) as? UITextView
        if answer == nil {
            answer = UITextView(frame: CGRect(x: 32, y: 32, width: background!.frame.width-64, height: background!.frame.height-64))
            answer!.textColor = UIColor(white: 0.7, alpha: 1)
            answer!.textAlignment = .center
            answer!.font = UIFont(name: "Helvetica", size: 20)
            answer!.tag = 3
            answer!.isEditable = false
            answer!.backgroundColor = UIColor(white: 0.95, alpha: 1)
            answer!.isSelectable = false
            answer!.alpha = 0
            answer!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StudyViewController.didTapTextView(_:))))
            background?.addSubview(answer!)
        }
        answer?.alpha = 0
        answer?.text = card["answer"]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        flipCell(indexPath)
    }
    
    func didTapTextView(_ tap:UITapGestureRecognizer) {
        
        flipCell(collectionView.indexPathForItem(at: tap.location(in: collectionView))!)
        
        
    }
    
    func flipCell(_ indexPath:IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let background = cell?.contentView.viewWithTag(1)
        let question = background?.viewWithTag(2) as! UILabel
        let answer = background?.viewWithTag(3) as! UITextView
        if question.alpha == 1 {
            question.alpha = 0
            answer.alpha = 1
        }else{
            question.alpha = 1
            answer.alpha = 0
        }
        UIView.transition(with: background!, duration: 0.3, options: [.allowUserInteraction, .transitionFlipFromTop] , animations: {
            
            }, completion: nil)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let cards = dict!["cards"] as! [[String:String]]
        
        // Calculate where the collection view should be at the right-hand end item
        let contentOffsetWhenFullyScrolledRight = self.collectionView.frame.size.width*(CGFloat)(cards.count-1)
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            // user is scrolling to the right from the last item to the 'fake' item 1.
            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
            
            let newIndexPath = IndexPath(item: 1, section: 0)
            
            self.collectionView.scrollToItem(at: newIndexPath, at: UICollectionViewScrollPosition.left, animated: false)
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            // user is scrolling to the left from the first item to the fake 'item N'.
            // reposition offset to show the 'real' item N at the right end end of the collection view
            
            let newIndexPath = IndexPath(item: cards.count-2, section: 0)
            
            self.collectionView.scrollToItem(at: newIndexPath, at: UICollectionViewScrollPosition.left, animated: false)
            
        }
        
        if collectionView.visibleCells.count > 0 {
            var index = collectionView.indexPath(for: collectionView.visibleCells.first!)?.item
            if index == 0 {
                index = cards.count-2
            }else if index == cards.count-1 {
                index = 1
            }
            currentCardIndex.text = "\(index!) out of \(cards.count-2)"
        }
        
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            var cards = originalDict["cards"] as! [[String:String]]
            cards.shuffleInPlace()
            dict["cards"] = cards
            setupData()
            collectionView.reloadData()
        }
    }
    
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}


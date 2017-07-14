//
//  LibraryViewController.swift
//  flashcards
//
//  Created by Josh Arnold on 14/03/16.
//  Copyright © 2016 Josh Arnold. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var flashcardArray:[AnyObject]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryViewController.refreshLibrary), name: NSNotification.Name(rawValue: "refreshLibrary"), object: nil)
       refreshLibrary()
        
    }
    
    func refreshLibrary() {
        if UserDefaults.standard.object(forKey: "flashcardArray") != nil {
            flashcardArray = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
        }else{
            flashcardArray = []
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flashcardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        cell.clipsToBounds = true
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let dict = flashcardArray[indexPath.row]
        let title = dict["title"] as! String
        
        var titleLabel = cell.contentView.viewWithTag(1) as? UILabel
        if titleLabel == nil {
        titleLabel = UILabel(frame: CGRect(x: 4, y: 4, width: cell.frame.width-8, height: cell.frame.height-8))
        titleLabel!.textColor = UIColor(white: 0.5, alpha: 1)
        titleLabel!.numberOfLines = 0
        titleLabel!.textAlignment = .center
        titleLabel!.tag = 1
        cell.contentView.addSubview(titleLabel!)
        }
        titleLabel!.text = title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width-64)/3,height: ((view.frame.width-64)/3)+40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DeckViewController()
        vc.dict = flashcardArray[indexPath.row] as! [AnyHashable: Any] as [NSObject : AnyObject]
        vc.index = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addDeck(_ sender: AnyObject) {
        present(UINavigationController(rootViewController:CreateDeckViewController()), animated: true, completion: nil)
    }
    
}

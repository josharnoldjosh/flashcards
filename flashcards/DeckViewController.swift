//
//  DeckViewController.swift
//  flashcards
//
//  Created by Josh Arnold on 13/04/16.
//  Copyright © 2016 Josh Arnold. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DeckViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var titleTextField:UITextField!
    var dict:[AnyHashable: Any]!
    var index:Int!
    var tableView:UITableView!
    var isDeleted:Bool! = false
    var editDeckButton:UIBarButtonItem!
    var toolbar:UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Deck"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Study", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeckViewController.studyDeck))
        
        NotificationCenter.default.addObserver(self, selector: #selector(DeckViewController.refreshDeck), name: NSNotification.Name(rawValue: "refreshDeck"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DeckViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
        
        titleTextField = UITextField(frame: CGRect(x: 16, y: 72, width: view.frame.width-16, height: 40))
        titleTextField.placeholder = "Title"
        titleTextField.text = dict["title"] as? String
        titleTextField.font = UIFont(name:"HelveticaNeue-Bold", size:16)
        view.addSubview(titleTextField)
        
        let line = UIView(frame: CGRect(x: 16, y: titleTextField.frame.maxY+4, width: view.frame.width-16, height: 1))
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addSubview(line)
        
        tableView = UITableView(frame: CGRect(x: 0, y: line.frame.maxY, width: view.frame.width, height: view.frame.height-(line.frame.maxY+8)-45))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        for view in tableView.subviews { // This is me being a little bit anal about delaying content touches
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).delaysContentTouches = false
            }
        }
        view.addSubview(tableView)
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.height-45, width: view.frame.width, height: 45))
        view.addSubview(toolbar)
        editDeckButton = UIBarButtonItem(title: "Edit Deck", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeckViewController.editDeck))
        let addCard = UIBarButtonItem(title: "Add Card", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeckViewController.addCard))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems( [addCard,space,editDeckButton], animated: false)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if isDeleted == false {
            let title = titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            if title?.characters.count > 0 {
                dict["title"] = title
            }else{
                dict["title"] = "Untitled"
            }
            
            saveDeck()
            
        }
    }
    
    func saveDeck() {
        var array = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
        array.remove(at: index)
        array.insert(dict as AnyObject, at: index)
        UserDefaults.standard.set(array, forKey: "flashcardArray")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshLibrary"), object: nil)
    }
    
    func refreshDeck() {
        var array = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
        dict = array[index] as! [AnyHashable: Any]
        tableView.reloadData()
    }
    
    func hideKeyboard() {
        view.endEditing(true)
        saveDeck()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dict["cards"] != nil {
            let cards = dict["cards"] as! [[AnyHashable: Any]]
            return cards.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var spacing:CGFloat! = 32
        if tableView.isEditing == true {
            spacing = 120
        }
        if dict["cards"] != nil {
            let cards = dict["cards"] as! [[AnyHashable: Any]]
            let card = cards[indexPath.row]
            let question = (card["question"] as! String).heightWithConstrainedWidth(view.frame.width-spacing, font: UIFont(name:"HelveticaNeue", size:16)!)
            var answer = (card["answer"] as! String).heightWithConstrainedWidth(view.frame.width-spacing, font: UIFont(name:"HelveticaNeue", size:14)!)
            if answer > 100 {
                answer = 100
            }
            return 16 + question + 8 + answer + 16
        }
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        
        if tableView.isEditing == true {
            let edit = UIButton(frame: CGRect(x: view.frame.width-30, y: 0, width: 30, height: cell.frame.height))
            edit.setImage(UIImage(named: "edit"), for: UIControlState())
            edit.imageView?.contentMode = .scaleAspectFit
            edit.addTarget(self, action: #selector(DeckViewController.deleteCard(_:event:)), for: UIControlEvents.touchUpInside)
            cell.editingAccessoryView = edit
        }else{
            cell.editingAccessoryView = nil
        }
        
        var spacing:CGFloat! = 32
        if tableView.isEditing == true {
            spacing = 120
        }
        
        if dict["cards"] != nil {
            let cards = dict["cards"] as! [[AnyHashable: Any]]
            let card = cards[indexPath.row]
            let question = (card["question"] as! String).heightWithConstrainedWidth(view.frame.width-spacing, font: UIFont(name:"HelveticaNeue", size:16)!)
            var answer = (card["answer"] as! String).heightWithConstrainedWidth(view.frame.width-spacing, font: UIFont(name:"HelveticaNeue", size:14)!)
            if answer > 100 {
                answer = 100
            }
            
            var questionLabel = cell.contentView.viewWithTag(1) as? UILabel
            if questionLabel == nil {
                questionLabel = UILabel(frame: CGRect(x: 16, y: 16, width: view.frame.width-spacing, height: question))
                questionLabel!.font = UIFont(name:"HelveticaNeue", size:16)
                questionLabel!.numberOfLines = 0
                questionLabel!.tag = 1
                questionLabel?.textColor = UIColor(white: 0.15, alpha: 1)
                cell.contentView.addSubview(questionLabel!)
            }
            questionLabel!.text = card["question"] as? String
            
            var answerLabel = cell.contentView.viewWithTag(2) as? UILabel
            if answerLabel == nil {
                answerLabel = UILabel(frame: CGRect(x: 16, y: questionLabel!.frame.maxY+8, width: view.frame.width-spacing, height: answer))
                answerLabel!.font = UIFont(name:"HelveticaNeue", size:14)
                answerLabel!.numberOfLines = 0
                answerLabel!.tag = 2
                answerLabel?.textColor = UIColor(white: 0.5, alpha: 1)
                cell.contentView.addSubview(answerLabel!)
            }
            answerLabel!.text = card["answer"] as? String
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if self.dict["cards"] != nil {
            var cards = self.dict["cards"] as! [[AnyHashable: Any]]
            let card = cards[indexPath.row]
            
            let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to delete \"\(card["question"]!)\"", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancel)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (UIAlertAction) in
                cards.remove(at: indexPath.row)
                self.dict["cards"] = cards
                tableView.reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.automatic)
                self.saveDeck()
            }
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if dict["cards"] != nil {
            var cards = dict["cards"] as! [[AnyHashable: Any]]
            let card = cards[sourceIndexPath.row]
            cards.remove(at: sourceIndexPath.row)
            cards.insert(card, at: destinationIndexPath.row)
            dict["cards"] = cards
            saveDeck()
        }
    }
    
    func addCard() {
        let vc = AddCardViewController()
        vc.dict = dict! as [NSObject : AnyObject]
        vc.index = index
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
    }
    
    func editDeck() {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editDeckButton.title = "Edit Deck"
            let addCard = UIBarButtonItem(title: "Add Card", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeckViewController.addCard))
            let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems( [addCard,space,editDeckButton], animated: true)
        }else{
            tableView.setEditing(true, animated: true)
            editDeckButton.title = "Done Editing"
            let delete = UIBarButtonItem(title: "Delete Deck", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeckViewController.deleteDeck))
            let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems( [delete,space,editDeckButton], animated: true)
        }
        tableView.reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.automatic)
    }
    
    func deleteCard(_ sender:UIButton, event:UIEvent) {
        
        let touch = event.touches(for: sender)?.first
        let row = tableView.indexPathForRow(at: (touch?.previousLocation(in: tableView))!)!.row
        
        var cards = dict["cards"] as! [[String:String]]
        let card = cards[row]
        
        let alert = UIAlertController(title: "Edit", message: "\"\(card["question"]!)\"", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        let edit = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (UIAlertAction) in
            let vc = EditCardViewController()
            vc.dict = self.dict! as [NSObject : AnyObject]
            vc.index = self.index
            vc.cardIndex = row
            self.present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
        }
        alert.addAction(edit)
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (UIAlertAction) in
            cards.remove(at: row)
            self.dict["cards"] = cards
            self.saveDeck()
            self.tableView.reloadSections(IndexSet(integer:0), with: UITableViewRowAnimation.automatic)
        }
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteDeck() {
        let alert = UIAlertController(title: "Delete this flash card deck?", message: "Are you sure you want to delete this flash card deck sending it hell to experience pain and suffering for all of eternity?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (UIAlertAction) in
            self.isDeleted = true
            var array = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
            array.remove(at: self.index)
            UserDefaults.standard.set(array, forKey: "flashcardArray")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshLibrary"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    func studyDeck() {
        let vc = StudyViewController()
        vc.dict = dict! as [NSObject : AnyObject]
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
    }
    
}

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

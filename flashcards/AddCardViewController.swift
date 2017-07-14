//
//  AddCardViewController.swift
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


class AddCardViewController: UIViewController, UIScrollViewDelegate,UITextViewDelegate {
    
    var dict:[AnyHashable: Any]!
    var index:Int!
    var scrollView:UIScrollView!
    var questionTextField:UITextField!
    var answerTextView:UITextView!
    var answerTextViewPlaceholder:UILabel!
    var createButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a Card"
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddCardViewController.cancel))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        
        questionTextField = UITextField(frame: CGRect(x: 16, y: 16, width: view.frame.width-16, height: 40))
        questionTextField.placeholder = "Question"
        questionTextField.font = UIFont(name:"HelveticaNeue-Bold", size:16)
        questionTextField.addTarget(self, action: #selector(AddCardViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        scrollView.addSubview(questionTextField)
        questionTextField.becomeFirstResponder()
        
        let line = UIView(frame: CGRect(x: 16, y: questionTextField.frame.maxY+4, width: view.frame.width-16, height: 1))
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        scrollView.addSubview(line)
        
        answerTextView = UITextView(frame: CGRect(x: 12, y: line.frame.maxY+8, width: view.frame.width-24, height: 40))
        answerTextView.font = UIFont(name:"HelveticaNeue", size:16)
        answerTextView.delegate = self
        scrollView.addSubview(answerTextView)
        
        answerTextViewPlaceholder = UILabel(frame: CGRect(x: 16, y: line.frame.maxY+8, width: view.frame.width-32, height: 36))
        answerTextViewPlaceholder.text = "Answer"
        answerTextViewPlaceholder.textColor = UIColor(white: 0.8, alpha: 1)
        scrollView.addSubview(answerTextViewPlaceholder)
        
        createButton = UIButton(type: UIButtonType.system)
        createButton.frame = CGRect(x: 16, y: answerTextView.frame.maxY+8, width: view.frame.width-32, height: 40)
        createButton.setTitle("Add Card", for: UIControlState())
        createButton.addTarget(self, action: #selector(AddCardViewController.addCard), for: UIControlEvents.touchUpInside)
        createButton.isEnabled = false
        scrollView.addSubview(createButton)
        
    }
    
    func cancel() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if answerTextView.text.characters.count > 0 && questionTextField.text?.characters.count > 0 {
            createButton.isEnabled = true
        }else{
            createButton.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.characters.count > 0 && questionTextField.text?.characters.count > 0 {
            createButton.isEnabled = true
        }else{
            createButton.isEnabled = false
        }
        
        if textView.text.characters.count > 0 {
            self.answerTextViewPlaceholder.alpha = 0
        }else{
            self.answerTextViewPlaceholder.alpha = 1
        }
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
        UIView.animate(withDuration: 0.5, animations: {
            textView.frame.size.height = size.height
            self.createButton.frame.origin.y = textView.frame.maxY+8
        }) 
        
        scrollView.contentSize.height = view.frame.height+size.height-120
        
    }
    
    func addCard() {
        
        createButton.isEnabled = false
        
        var cards:[[String:String]]! = []
        let question = questionTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let answer = answerTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if dict["cards"] != nil {
            cards = dict["cards"] as! [[String:String]]!
        }
        
        cards.append(["question":question!,"answer":answer!])
        
        dict["cards"] = cards
        
        var array = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
        array.remove(at: index)
        array.insert(dict as AnyObject, at: index)
        UserDefaults.standard.set(array, forKey: "flashcardArray")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshDeck"), object: nil)
        
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    
}

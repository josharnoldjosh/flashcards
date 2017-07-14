//
//  CreateDeckViewController.swift
//  flashcards
//
//  Created by Josh Arnold on 13/04/16.
//  Copyright © 2016 Josh Arnold. All rights reserved.
//

import UIKit

class CreateDeckViewController: UIViewController, UIScrollViewDelegate {
    
    var titleTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create a Deck"
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateDeckViewController.cancel))
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        
        titleTextField = UITextField(frame: CGRect(x: 16, y: 16, width: view.frame.width-16, height: 40))
        titleTextField.placeholder = "Title"
        scrollView.addSubview(titleTextField)
        titleTextField.becomeFirstResponder()
        
        let line = UIView(frame: CGRect(x: 16, y: titleTextField.frame.maxY+4, width: view.frame.width-16, height: 1))
        line.backgroundColor = UIColor(white: 0.9, alpha: 1)
        scrollView.addSubview(line)
        
        let createButton = UIButton(type: UIButtonType.system)
        createButton.frame = CGRect(x: 16, y: line.frame.maxY+8, width: view.frame.width-32, height: 40)
        createButton.setTitle("Create Deck", for: UIControlState())
        createButton.addTarget(self, action: #selector(CreateDeckViewController.createDeck), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(createButton)
        
    }
    
    func createDeck() {
        var title = titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        if title == "" {
            title = "Untitled"
        }
        var array:[AnyObject]! = []
        if UserDefaults.standard.object(forKey: "flashcardArray") != nil {
        array = UserDefaults.standard.object(forKey: "flashcardArray") as! [AnyObject]
        }
        
        let dict:[String:AnyObject] = ["title":title! as AnyObject]
        
        array.append(dict as AnyObject)
        UserDefaults.standard.set(array, forKey: "flashcardArray")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshLibrary"), object: nil)
        cancel()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func cancel() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  ViewController.swift
//  ChatViewController
//
//  Created by Emil Gräs on 11/09/2016.
//  Copyright © 2016 Emil Gräs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var messages: [Message]!
    private var messageTextViewOriginalYPosition: CGFloat!
    private var messageTextViewOriginalHeight: CGFloat!
    private var keyboardHeight: CGFloat?
    private let textViewHeight:CGFloat = 50
    private var keyboardPresented = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var textViewBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBAction func sendMessageButtonTapped(sender: AnyObject) {
        if !messageTextView.text.isEmpty {
            
            // This is the place to uplad the message to firebase
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            let message = messageTextView.text.stringByTrimmingCharactersInSet(spacing)
            
            messages.append(Message(author: "Anonoumous", message: message))
            tableView.reloadData()
            let indexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            
            // reset to old values
            messageTextView.text = ""
            messageTextView.frame.origin.y = messageTextViewOriginalYPosition
            messageTextView.frame.size.height = messageTextViewOriginalHeight
            textViewHeightConstraint.constant = textViewHeight
            sendMessageButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup delegates
        tableView.dataSource = self
        tableView.delegate = self
        messageTextView.delegate = self
        
        // initial setup
        sendMessageButton.enabled = false
        messageTextView.layer.cornerRadius = 4
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // initialize variables
        messageTextViewOriginalYPosition = messageTextView.frame.origin.y
        messageTextViewOriginalHeight = messageTextView.frame.height
        
        // Load all the messages from firebase and reload tableview
        messages = Message.getDummyMessages()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboardEvents()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboardEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll to the bottom :)
        let indexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup Keyboard Observers
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.changeInputMode(_:)), name: UITextInputCurrentInputModeDidChangeNotification, object: nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextInputCurrentInputModeDidChangeNotification, object: nil)
    }
    
    // MARK: - Keyboard Observer Methods
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                
                let keyboardModeDiff = keyboardSize.height - 216
                
                if !keyboardPresented {
                    
                    // First time
                    
                    self.keyboardHeight = keyboardSize.height
                    self.textViewBottomContraint.constant = keyboardSize.height
                    UIView.animateWithDuration(0.5, animations: {
                        self.view.layoutIfNeeded()
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + keyboardSize.height)
                    })
                    keyboardPresented = true
                    return
                }
                
                
                if keyboardSize.height == 216 {

                    // Normal Keyboard
                    
                    self.keyboardHeight = keyboardSize.height
                    self.textViewBottomContraint.constant = keyboardSize.height
                    UIView.animateWithDuration(0.5, animations: {
                        self.view.layoutIfNeeded()
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - keyboardModeDiff)
                    })
                        
                } else {
                    
                    // Emoji Keyboard
                    
                    self.keyboardHeight = keyboardSize.height
                    self.textViewBottomContraint.constant += keyboardModeDiff
                    UIView.animateWithDuration(0.5, animations: {
                        self.view.layoutIfNeeded()
                        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + keyboardModeDiff)
                    })
                }
                
                
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardPresented = false
        if let userInfo = notification.userInfo {
            if let _: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                self.textViewBottomContraint.constant = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc private func changeInputMode(notification : NSNotification)
    {
        let inputMethod = UITextInputMode.activeInputModes()
        print("inputMethod: \(inputMethod)")
    }

}


extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! ChatCell
        cell.message = messages[indexPath.row]
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}


extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        
        // First, check if the TextView contains any text
        
        // If it is empty the send button is disabled - otherwise it is enabled
        
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        if !messageTextView.text.stringByTrimmingCharactersInSet(spacing).isEmpty {
            sendMessageButton.enabled = true
        } else {
            sendMessageButton.enabled = false
        }
        
        
        
        
        // Next,
        
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.height
            
            // redefine textview frame
            textView.frame.origin.y -= difference
            textView.frame.size.height = textView.contentSize.height
            textViewHeightConstraint.constant += difference
            
            // move up tableview
            if textView.contentSize.height + keyboardHeight! + messageTextViewOriginalYPosition >= tableView.frame.size.height {
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + difference)
                //tableView.frame.size.height -= difference
            }
            
        } else if textView.contentSize.height < textView.frame.height {
            
            // find difference to deduct
            let difference = textView.frame.height - textView.contentSize.height
            
            // redefine textview frame
            textView.frame.origin.y += difference
            textView.frame.size.height = textView.contentSize.height
            textViewHeightConstraint.constant -= difference
            
            // move down tableview
            if textView.contentSize.height + keyboardHeight! + messageTextViewOriginalYPosition > tableView.frame.height {
                //tableView.frame.size.height += difference
            }
            
        }
        
    }
    
}



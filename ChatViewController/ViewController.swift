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
    private var messageContainerViewOriginalHeight: CGFloat!

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var textViewBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var realTextViewHeightConstraint: NSLayoutConstraint!
    @IBAction func sendMessageButtonTapped(sender: AnyObject) {
        if !messageTextView.text.isEmpty {
            
            // This is the place to uplad the message to firebase
            let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            let message = messageTextView.text.stringByTrimmingCharactersInSet(spacing)
            
            messages.append(Message(author: "Anonoumous", message: message))
            //tableView.reloadData()
            let indexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            
            
            
            
            
            // reset textview height to original
            messageTextView.text = ""
            realTextViewHeightConstraint.constant = messageTextViewOriginalHeight
            
            // reset table view insets
            // ------------------ TODO: move to method ------------------
            tableView.contentInset.bottom = messageContainerViewOriginalHeight + keyboardHeight!
            tableView.scrollIndicatorInsets.bottom = messageContainerViewOriginalHeight + keyboardHeight!
            // ------------------ TODO: move to method ------------------
            
            
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            
            //messageTextView.frame.origin.y = messageTextViewOriginalYPosition
            //messageTextView.frame.size.height = messageTextViewOriginalHeight
            //textViewHeightConstraint.constant = textViewHeight

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
        messageContainerViewOriginalHeight = messageContainerView.frame.height
        sendMessageButton.enabled = false
        messageTextView.layer.cornerRadius = 16
        
        // ------------------ TODO: move to method ------------------
        tableView.contentInset.bottom = messageContainerViewOriginalHeight
        tableView.scrollIndicatorInsets.bottom = messageContainerViewOriginalHeight
        // ------------------ TODO: move to method ------------------
        
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
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Observer Methods
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {

                self.keyboardHeight = keyboardSize.height

                UIView.animateWithDuration(0.4, animations: {
                    self.tableView.contentInset.bottom = keyboardSize.height + self.messageContainerView.frame.height
                    self.tableView.scrollIndicatorInsets.bottom = keyboardSize.height + self.messageContainerView.frame.height
                })

                // move up texview
                self.textViewBottomContraint.constant = keyboardSize.height
                self.view.layoutIfNeeded()
                
                // scroll to bottom
                let indexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                
                
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let _: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                
                tableView.contentInset.bottom = messageContainerViewOriginalHeight
                tableView.scrollIndicatorInsets.bottom = messageContainerViewOriginalHeight
                
                self.textViewBottomContraint.constant = 0
                self.view.layoutIfNeeded()
                
            }
        }
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
        
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        if !messageTextView.text.stringByTrimmingCharactersInSet(spacing).isEmpty {
            sendMessageButton.enabled = true
        } else {
            sendMessageButton.enabled = false
        }
        
        
        // TODO: - set max height
        
        let newSize = textView.sizeThatFits(CGSizeMake(textView.frame.width, CGFloat.max))
        realTextViewHeightConstraint.constant = newSize.height
        
        
        let difference = newSize.height - textView.frame.height
        tableView.contentInset.bottom += difference
        tableView.scrollIndicatorInsets.bottom += difference

        // This should not always be called.
        let indexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        
    }
    
}



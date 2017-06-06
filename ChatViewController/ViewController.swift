//
//  ViewController.swift
//  ChatViewController
//
//  Created by Emil Gräs on 11/09/2016.
//  Copyright © 2016 Emil Gräs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var messages: [Message]!
    fileprivate var messageTextViewOriginalYPosition: CGFloat!
    fileprivate var messageTextViewOriginalHeight: CGFloat!
    fileprivate var keyboardHeight: CGFloat?
    fileprivate let textViewHeight:CGFloat = 50
    fileprivate var messageContainerViewOriginalHeight: CGFloat!

    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var textViewBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var realTextViewHeightConstraint: NSLayoutConstraint!
    @IBAction func sendMessageButtonTapped(_ sender: AnyObject) {
        if !messageTextView.text.isEmpty {
            
            // This is the place to uplad the message to firebase
            let spacing = CharacterSet.whitespacesAndNewlines
            let message = messageTextView.text.trimmingCharacters(in: spacing)
            
            messages.append(Message(author: "Anonoumous", message: message))
            //tableView.reloadData()
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
            
            
            
            
            
            // reset textview height to original
            messageTextView.text = ""
            realTextViewHeightConstraint.constant = messageTextViewOriginalHeight
            
            // reset table view insets
            // ------------------ TODO: move to method ------------------
            tableView.contentInset.bottom = messageContainerViewOriginalHeight + keyboardHeight!
            tableView.scrollIndicatorInsets.bottom = messageContainerViewOriginalHeight + keyboardHeight!
            // ------------------ TODO: move to method ------------------
            
            
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            
            //messageTextView.frame.origin.y = messageTextViewOriginalYPosition
            //messageTextView.frame.size.height = messageTextViewOriginalHeight
            //textViewHeightConstraint.constant = textViewHeight

            sendMessageButton.isEnabled = false
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
        sendMessageButton.isEnabled = false
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
        
        messageTextView.textContainerInset.left = 6
        
        // Load all the messages from firebase and reload tableview
        messages = Message.getDummyMessages()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboardEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboardEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        // Scroll to the bottom :)
        let indexPath = IndexPath(row: messages.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup Keyboard Observers
    fileprivate func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func stopObservingKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Keyboard Observer Methods
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size {

                self.keyboardHeight = keyboardSize.height

                UIView.animate(withDuration: 0.4, animations: {
                    self.tableView.contentInset.bottom = keyboardSize.height + self.messageContainerView.frame.height
                    self.tableView.scrollIndicatorInsets.bottom = keyboardSize.height + self.messageContainerView.frame.height
                })

                // move up texview
                self.textViewBottomContraint.constant = keyboardSize.height
                self.view.layoutIfNeeded()
                
                // scroll to bottom
                let indexPath = IndexPath(row: messages.count-1, section: 0)
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                
                
            }
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let _: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size {
                
                tableView.contentInset.bottom = messageContainerViewOriginalHeight
                tableView.scrollIndicatorInsets.bottom = messageContainerViewOriginalHeight
                
                self.textViewBottomContraint.constant = 0
                self.view.layoutIfNeeded()
                
            }
        }
    }

}


extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.message = messages[indexPath.row]
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let spacing = CharacterSet.whitespacesAndNewlines
        if !messageTextView.text.trimmingCharacters(in: spacing).isEmpty {
            sendMessageButton.isEnabled = true
        } else {
            sendMessageButton.isEnabled = false
        }
        
        
        // TODO: - set max height
        
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        realTextViewHeightConstraint.constant = newSize.height
        
        
        let difference = newSize.height - textView.frame.height
        tableView.contentInset.bottom += difference
        tableView.scrollIndicatorInsets.bottom += difference

        // This should not always be called.
        let indexPath = IndexPath(row: messages.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        
    }
    
}



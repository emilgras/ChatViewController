//
//  Message.swift
//  ChatViewController
//
//  Created by Emil Gräs on 11/09/2016.
//  Copyright © 2016 Emil Gräs. All rights reserved.
//

import Foundation

class Message {
    var author: String!
    var message: String!
    
    init(author: String, message: String) {
        self.author = author
        self.message = message
    }
    
    static func getDummyMessages() -> [Message] {
        return [
            Message(author: "Hannibal", message: "Hello dear Cindy, how are you?"),
            Message(author: "Cindy", message: "Oh Hannibal, im glad you wrote. Im doing great, and you?. I actually thought we should grab some food soon. What do you say?"),
            Message(author: "Hannibal", message: "Sounds Great! 😍"),
            Message(author: "Hannibal", message: "Hello dear Cindy, how are you?"),
            Message(author: "Cindy", message: "Oh Hannibal, im glad you wrote. Im doing great, and you?. I actually thought we should grab some food soon. What do you say?"),
            Message(author: "Hannibal", message: "Sounds Great! 😍"),
            Message(author: "Hannibal", message: "Hello dear Cindy, how are you?"),
            Message(author: "Cindy", message: "Oh Hannibal, im glad you wrote. Im doing great, and you?. I actually thought we should grab some food soon. What do you say?"),
            Message(author: "Hannibal", message: "Sounds Great! 😍"),
            Message(author: "Hannibal", message: "Hello dear Cindy, how are you?"),
            Message(author: "Cindy", message: "Oh Hannibal, im glad you wrote. Im doing great, and you?. I actually thought we should grab some food soon. What do you say?"),
            Message(author: "Hannibal", message: "Sounds Great! 😍")
        ]
    }
    
}
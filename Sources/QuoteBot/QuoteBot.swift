//
//  QuoteBot.swift
//  QuoteBotPackageDescription
//
//  Created by Andrew Haentjens on 01/02/2018.
//

import Foundation
import SlackKit

class QuoteBot {
    
    enum Command: String {
        case addQuote = "addQuote"
        case showQuote = "showQuote"
    }
    
    let quoteBot: SlackKit
    let context = DataController.shared.container.viewContext
    
    var quotes: [Quote] = []
    
    init(token: String) {
        
        quoteBot = SlackKit()
        
        quoteBot.addRTMBotWithAPIToken(token)
        quoteBot.addWebAPIAccessWithToken(token)
        quoteBot.notificationForEvent(.message) { [weak self] (event, client) in
            
            guard let message = event.message,
                let id = client?.authenticatedUser?.id,
                message.text?.contains(id) == true else {
                    return
            }
            
            self?.handleMessage(message)
        }
        
    }
    
    init(clientID: String, clientSecret: String) {
        
        quoteBot = SlackKit()
        
        let oauthConfig = OAuthConfig(clientID: clientID, clientSecret: clientSecret)
        quoteBot.addServer(oauth: oauthConfig)
        quoteBot.notificationForEvent(.message) { [weak self] (event, client) in
            
            guard let message = event.message,
                let id = client?.authenticatedUser?.id,
                message.text?.contains(id) == true else {
                    return
            }
            
            self?.handleMessage(message)
        }
    }
    
    // MARK: Bot logic
    private func handleMessage(_ message: Message) {
        guard let text = message.text else {
            return
        }
        
        switch text {
        case let text where text.contains(Command.addQuote.rawValue):
            handleCommand(.addQuote, with: message)
        case let text where text.contains(Command.showQuote.rawValue):
            handleCommand(.showQuote, with: message)
        default:
            break
        }
    }
    
    private func handleCommand(_ command: Command, with message: Message) {
        guard
            let quoteText = message.text else {
                return
        }
        
        switch command {
        case .addQuote:
            
            let errorText = "Something fuckedy is going on here. Maybe you should make a Jira ticket about it?"
            let stringArray = quoteText.components(separatedBy: Command.addQuote.rawValue)
            
            if stringArray.count == 2 {
                let quoteToAdd = Quote(context: context)
                quoteToAdd.quote = stringArray[1]
                quoteToAdd.quoter = ""
                
                DataController.shared.saveContext()
                
            } else {
                guard let channel = message.channel else {
                    return
                }
                
                quoteBot.webAPI?.sendMessage(channel: channel, text: errorText, success: nil, failure: { (error) in
                    debugPrint(error.localizedDescription)
                })
            }
            
        case .showQuote:
            let randomNumber = randomInt(min: 0, max: quotes.count - 1)
            
            loadQuotes()
            
            guard
                let channel = message.channel,
                let quote = quotes[randomNumber].quote else {
                    return
            }
        
            quoteBot.webAPI?.sendMessage(channel: channel, text: quote, success: nil, failure: { (error) in
                debugPrint(error.localizedDescription)
            })
        }
    }
    
    private func loadQuotes() {
        let request = Quote.createFetchRequest()
        
        do {
            quotes = try context.fetch(request)
        } catch (let error) {
            debugPrint(error.localizedDescription)
        }
    }
    
    private func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}

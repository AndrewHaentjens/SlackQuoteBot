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
        case addQuote = "addquote"
        case showQuote = "showQuote"
    }
    
    struct Quote {
        var quote: String
        var quoter: String
    }
    
    let quoteBot: SlackKit
    
    var quotes: [Quote] = [
        Quote(quote: "Wa is den API van diene Cockring?", quoter: "Annihilator"),
        Quote(quote: "yo mama so fat that ben kenobi said 'that's no moon..'", quoter: "Albion"),
        Quote(quote: "Annihilator [4:01 PM] jah @linkmark die mag wel keer op mijne doedlezak blazen zenneeeh", quoter: "Albion")
    ]
    
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
        guard let quoteText = message.text/*, let quoter = message.username*/ else { return }
        
        switch command {
        case .addQuote:
            let quoteToAdd = Quote(quote: quoteText, quoter: "TEST")
            quotes.append(quoteToAdd)

        case .showQuote:
            guard let channel = message.channel else {
                return
            }
            
            let randomNumber = randomInt(min: 0, max: quotes.count - 1)
            let quote = quotes[randomNumber].quote
            
            quoteBot.webAPI?.sendMessage(channel: channel, text: quote, success: nil, failure: { [weak self] (error) in
                debugPrint(error.localizedDescription)
            })
        }
    }
    
    private func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}

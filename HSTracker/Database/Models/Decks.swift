//
//  Decks.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 17/04/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger

final class Decks {
    static let instance = Decks()
    
    private var _decks = [String: Deck]()
    
    private var savePath: String? {
        if let path = Settings.instance.deckPath {
            return "\(path)/decks.json"
        }
        return nil
    }
    
    init() {
        loadDecks()
    }
    
    private func loadDecks() {
        if let jsonFile = savePath, jsonData = NSData(contentsOfFile: jsonFile) {
            Log.verbose?.message("json file : \(jsonFile)")
            do {
                let decks: [String: [String: AnyObject]] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! [String: [String: AnyObject]]
                for (_, _deck) in decks {
                    if let deck = Deck.fromDict(_deck) where deck.isValid() {
                        _decks[deck.deckId] = deck
                    }
                }
            } catch {
            }
        }
    }
    
    func resetDecks() {
        loadDecks()
        NSNotificationCenter.defaultCenter().postNotificationName("reload_decks", object: nil)
    }
    
    func decks() -> [Deck] {
        return _decks.map { $0.1 }
    }
    
    func add(deck: Deck) {
        deck.creationDate = NSDate()
        _decks[deck.deckId] = deck
        save()
    }
    
    func update(deck: Deck) {
        _decks[deck.deckId] = deck
        save()
    }
    
    func remove(deck: Deck) {
        _decks[deck.deckId] = nil
        save()
    }
    
    internal func save() {
        var jsonDecks = [String: [String: AnyObject]]()
        for (deckId, deck) in _decks {
            jsonDecks[deckId] = deck.toDict()
        }
        if let jsonFile = savePath {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(jsonDecks, options: .PrettyPrinted)
                data.writeToFile(jsonFile, atomically: true)
            }
            catch {
                // TODO error
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("reload_decks", object: nil)
    }
    
    func byId(id: String) -> Deck? {
        return decks().filter({ $0.deckId == id }).first
    }
}

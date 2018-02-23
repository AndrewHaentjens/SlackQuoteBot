//
//  DataModel.swift
//  QuoteBotPackageDescription
//
//  Created by Andrew Haentjens on 22/02/2018.
//

import Foundation
import CoreData

@available(OSX 10.12, *)
class DataController {
    
    var container: NSPersistentContainer!
    
    static let shared = DataController()
    
    @available(OSX 10.12, *)
    init() {
        
        container = NSPersistentContainer(name: "DataModel")
        
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                debugPrint(error.debugDescription)
                return
            }
        }
        
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch (let error) {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
}

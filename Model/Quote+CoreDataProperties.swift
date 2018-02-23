//
//  Quote+CoreDataProperties.swift
//  QuoteBot
//
//  Created by Andrew Haentjens on 22/02/2018.
//
//

import Foundation
import CoreData

extension Quote {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Quote> {
        return NSFetchRequest<Quote>(entityName: "Quote")
    }

    @NSManaged public var quote: String?
    @NSManaged public var quoter: String?

}

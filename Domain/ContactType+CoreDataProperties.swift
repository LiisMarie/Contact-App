//
//  ContactType+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactType> {
        return NSFetchRequest<ContactType>(entityName: "ContactType")
    }

    @NSManaged public var name: String?
    @NSManaged public var contacts: NSSet?

}

// MARK: Generated accessors for contacts
extension ContactType {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contact)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contact)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

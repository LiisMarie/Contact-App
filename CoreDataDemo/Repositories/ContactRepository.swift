//
//  ContactRepository.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation
import CoreData

class ContactRepository {
    var container: NSPersistentContainer!
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func insert(contact: Contact) throws {
        context.insert(contact)
        try context.save()
    }
    
    func all() throws -> [Contact] {
        let request = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        let contacts = try context.fetch(request)
        return contacts
    }
    
    func update(contacts: Contact) throws {
        try context.save()
    }
    
    func delete(contacts: Contact) throws {
        context.delete(contacts)
        try context.save()
    }
}

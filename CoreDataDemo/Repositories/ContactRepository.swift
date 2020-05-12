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
        print("trying to insert")
        context.insert(contact)
        try context.save()
        print("tryng to insert successful")
    }
    
    func all() throws -> [Contact] {
        print("getting all contacts")
        let request = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        let contacts = try context.fetch(request)
        return contacts
    }
    
    func getByPerson(person: Person) throws -> [Contact] {
        let request = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        let contacts = try context.fetch(request)
        var contactsForPerson = [Contact]()
        for contact in contacts {
            if (contact.person == person) {
                contactsForPerson.append(contact)
            }
        }
        return contactsForPerson
    }
    
    func update(contacts: Contact) throws {
        try context.save()
    }
    
    func delete(contacts: Contact) throws {
        context.delete(contacts)
        try context.save()
    }
}

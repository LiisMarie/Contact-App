//
//  ContactTypeRepository.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation
import CoreData

class ContactTypeRepository {
    var container: NSPersistentContainer!
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func insert(contactType: ContactType) throws {
        context.insert(contactType)
        try context.save()
    }
    
    func all() throws -> [ContactType] {
        let request = NSFetchRequest<ContactType>(entityName: String(describing: ContactType.self))
        let contactTypes = try context.fetch(request)
        return contactTypes
    }
    
    func update(contactType: ContactType) throws {
        try context.save()
    }
    
    func delete(contactType: ContactType) throws {
        context.delete(contactType)
        try context.save()
    }
}

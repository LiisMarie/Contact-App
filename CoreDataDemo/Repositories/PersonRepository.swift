//
//  PersonRepository.swift
//  CoreDataDemo
//
//  Created by Liis on 11.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation
import CoreData

class PersonRepository {
    var container: NSPersistentContainer!
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func insert(person: Person) throws {
        context.insert(person)
        try context.save()
    }
    
    func all() throws -> [Person] {
        let request = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        let persons = try context.fetch(request)
        return persons
    }
    
    func update(person: Person) throws {
        try context.save()
    }
    
    func delete(person: Person) throws {
        context.delete(person)
        try context.save()
    }
}

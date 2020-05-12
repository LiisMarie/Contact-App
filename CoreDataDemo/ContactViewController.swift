//
//  ContactViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 12.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

class ContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var container: NSPersistentContainer!
    
    var personRepo: PersonRepository!
    var contactRepo: ContactRepository!
    var contactTypeRepo: ContactTypeRepository!
    
    var fetchControllerPerson: NSFetchedResultsController<Person>?
    var fetchControllerContact: NSFetchedResultsController<Contact>?
    var fetchControllerContactType: NSFetchedResultsController<ContactType>?
    
    var contactTypes = [String]()
    
    var selectedRow: Int = 0
    
    var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        container = AppDelegate.persistentContainer
        
        self.title = "\(person.firstName!) \(person.lastName!)"
        
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        /*let request = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()*/
        
        let requestContact = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        requestContact.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
        fetchControllerContact = NSFetchedResultsController(fetchRequest: requestContact, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerContact!.delegate = self
        try? fetchControllerContact!.performFetch()
        
        let requestPerson = NSFetchRequest<Person>(entityName: String(describing: Person.self))
        requestPerson.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchControllerPerson = NSFetchedResultsController(fetchRequest: requestPerson, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerPerson!.delegate = self
        try? fetchControllerPerson!.performFetch()
        
        let requestContactType = NSFetchRequest<ContactType>(entityName: String(describing: ContactType.self))
        requestContactType.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchControllerContactType = NSFetchedResultsController(fetchRequest: requestContactType, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchControllerContactType!.delegate = self
        try? fetchControllerContactType!.performFetch()
        /*
        do {
            
            let contactTypesList = try contactTypeRepo.all()
            let contact = Contact(context: self.contactRepo.context)
            contact.value = "122"
            contact.person = self.person
            contact.contactType = contactTypesList[0]
            try? self.contactRepo.insert(contact: contact)
            
            
            print("displayed all contacts")
        } catch {
            print("Failed!")
        }*/
    }
    
    
    @IBAction func addContactTouchUpInside(_ sender: Any) {
        self.selectedRow = 0
        contactTypes = [String]()
        
        var contactTypesList = [ContactType]()
        do {
            contactTypesList = try contactTypeRepo.all()
            for contactType in contactTypesList {
                contactTypes.append(contactType.name!)
            }
        } catch {
            return
        }
    
        let alertController = UIAlertController(title: "Add contact for \(self.person.firstName!) \(self.person.lastName!)", message: "\n\n\n\n\n", preferredStyle: .alert)

        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alertController.view.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //alertController.setValue(vc, forKey: "ContactViewController")
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            print("\(self.selectedRow)")
            
            let contact = Contact(context: self.contactRepo.context)
            contact.value = alertController.textFields?[0].text
            contact.person = self.person
            contact.contactType = contactTypesList[self.selectedRow]
            print("before insertion")
            try? self.contactRepo.insert(contact: contact)
            print("after insertion")

        }))
        
        alertController.addTextField { textField in
            textField.placeholder = "Value"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.contactTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.contactTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }
    
}

extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchControllerContact?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        guard let contact = self.fetchControllerContact?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        cell.value?.text = "\(contact.value!)"
        // todo setting image too
        
        return cell
    }
    
    
}

extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let contact = self.fetchControllerContact?.object(at: indexPath) else {return}
            try? contactRepo.delete(contacts: contact)
        }
    }
}

extension ContactViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.reloadData()
        @unknown default:
            fatalError("unknown")
        }
    }
}

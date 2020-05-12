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
    
    var fetchController: NSFetchedResultsController<Contact>?

    var pickerItems = [String]()
    
    var pickerSelectedRow: Int?
    
    var person : Person?
    var contactType: ContactType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        container = AppDelegate.persistentContainer
        
        self.title = "\(person!.firstName!) \(person!.lastName!)"
        
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let requestContact = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        requestContact.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
        if (person != nil) {
            requestContact.predicate = NSPredicate(format: "person = %@", person!)
        }
        if (contactType != nil) {
            requestContact.predicate = NSPredicate(format: "contactType = %@", contactType!)
        }
        fetchController = NSFetchedResultsController(fetchRequest: requestContact, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchController!.delegate = self
        try? fetchController!.performFetch()
    }
    
    
    @IBAction func addContactTouchUpInside(_ sender: Any) {
        self.pickerSelectedRow = 0
        pickerItems = [String]()
        
        var alertTitle = ""
        do {
            if person != nil {
                alertTitle = person!.firstName! + " " + person!.lastName!
                for contactType in try contactTypeRepo.all() {
                    pickerItems.append(contactType.name!)
                }
            }
            if contactType != nil {
                alertTitle = contactType!.name!
                for person in try personRepo.all() {
                    pickerItems.append(person.firstName! + " " + person.lastName!)
                }
            }
        } catch {
            return
        }
    
        let alertController = UIAlertController(title: "Add contact for " + alertTitle, message: "\n\n\n\n\n", preferredStyle: .alert)

        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alertController.view.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
                
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            print("\(self.pickerSelectedRow!)")
            
            self.addNewContact(contactValue: alertController.textFields![0].text!)

        }))
        
        alertController.addTextField { textField in
            textField.placeholder = "Value"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addNewContact(contactValue: String) {
        var _person : Person!
        var _contactType : ContactType!
        if person == nil {
            _contactType = contactType!
            _person = try! personRepo.all()[pickerSelectedRow!]
        }
        if contactType == nil {
            _person = person!
            _contactType = try! contactTypeRepo.all()[pickerSelectedRow!]
        }
        
        let contact = Contact(context: self.contactRepo.context)
        contact.contactType = _contactType
        contact.person = _person
        contact.value = contactValue
        try! contactRepo.insert(contact: contact)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerItems[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerSelectedRow = row
    }
    
}

extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        guard let contact = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        cell.value?.text = "\(contact.value!)"
        // todo setting image too
        cell.imageView?.image = UIImage(named: (contact.contactType?.name!)!)
        
        return cell
    }
    
    
}

extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let contact = self.fetchController?.object(at: indexPath) else {return}
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

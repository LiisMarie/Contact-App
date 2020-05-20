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
    
    @IBOutlet weak var btnAddContact: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = AppDelegate.persistentContainer
                
        // setting repositories
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        // setting up tableview
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        // init fetchcontroller based on whether we are looking at persons contacts or contacts of specific type
        let requestContact = NSFetchRequest<Contact>(entityName: String(describing: Contact.self))
        requestContact.sortDescriptors = [NSSortDescriptor(key: "value", ascending: true)]
        if (person != nil) {
            requestContact.predicate = NSPredicate(format: "person = %@", person!)
            self.title = "\(person!.firstName!) \(person!.lastName!)"
            headerLabel.text = "\(person!.firstName!) \(person!.lastName!)"
        }
        if (contactType != nil) {
            requestContact.predicate = NSPredicate(format: "contactType = %@", contactType!)
            self.title = "\(contactType!.name!)"
            headerLabel.text = "\(contactType!.name!)"

        }
        fetchController = NSFetchedResultsController(fetchRequest: requestContact, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchController!.delegate = self
        try? fetchController!.performFetch()
        
        // make add contact button look nice
        btnAddContact.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        btnAddContact.layer.cornerRadius = 10
    }
    
    // logic for adding contact
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
    
    // setting up the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        
        guard let cellItem = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        
        if (person != nil) {
            cell.value?.text = "\(cellItem.value!)"
            cell.name?.text = ""
        }
        
        if (contactType != nil) {
            cell.value?.text = "\(cellItem.value!)"
            cell.name?.text = "\(cellItem.person!.firstName!) \(cellItem.person!.lastName!)"
        }
        
        cell.imageView?.image = UIImage(named: (cellItem.contactType?.name!)!)
        
        return cell
    }
    
    
}

extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    // contact deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let contact = self.fetchController?.object(at: indexPath) else {return}
            try? contactRepo.delete(contacts: contact)
        }
    }
    
    // contact editing
    internal func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") {
            (contextualAction, view, actionPerformed: (Bool) -> ()) in
            print("Edit clicked")
            
            guard let contact = self.fetchController?.object(at: indexPath) else {return}
            let alertController = UIAlertController(title: "Edit contact", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Save changes", style: .default, handler: {_ in
                let value = alertController.textFields?[0].text
                contact.value = value!
                try? self.contactRepo.update(contacts: contact)
                
            }))
            alertController.addTextField { textField in
                textField.text = "\(contact.value!)"
            }

            
            self.present(alertController, animated: true, completion: nil)
        }
        return UISwipeActionsConfiguration(actions: [edit])
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

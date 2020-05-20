//
//  ContactTypesViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 13.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit
import CoreData

// cell identifier ContactTypeCell

class ContactTypesViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    var personRepo: PersonRepository!
    var contactRepo: ContactRepository!
    var contactTypeRepo: ContactTypeRepository!
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchController: NSFetchedResultsController<ContactType>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        container = AppDelegate.persistentContainer
        
        personRepo = PersonRepository(container: container)
        contactRepo = ContactRepository(container: container)
        contactTypeRepo = ContactTypeRepository(container: container)
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let request = NSFetchRequest<ContactType>(entityName: String(describing: ContactType.self))
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController!.delegate = self
        
        try? fetchController!.performFetch()
                
    }
}

extension ContactTypesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactTypeCell", for: indexPath) as! ContactTypeTableViewCell
        guard let contactType = self.fetchController?.object(at: indexPath) else {
            return cell
        }
        
        cell.selectionStyle = .none
        
        cell.contactType?.text = "\(contactType.name!)"
        cell.icon?.image = UIImage(named: (contactType.name!))

        do {
            let contacts = try contactRepo.all()
            var personContacts =  0
            for contact in contacts {
                if contact.contactType == contactType {
                    personContacts += 1
                }
            }
            
            cell.details?.text = "\(personContacts) contacts"
        } catch {
            cell.details?.text = "0 contacts"
        }
        
        return cell
    }
    
}

extension ContactTypesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        let contactType = (self.fetchController?.object(at: indexPath))
        if (contactType != nil) {
            viewController.contactType = contactType!
            viewController.person = nil
        }
        present(viewController, animated: true, completion: nil)
    }
}

extension ContactTypesViewController: NSFetchedResultsControllerDelegate {
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

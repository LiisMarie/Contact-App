//
//  PrimarySplitViewController.swift
//  CoreDataDemo
//
//  Created by Liis on 12.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation
import UIKit

class PrimarySplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}

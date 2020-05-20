//
//  ContactTypeTableViewCell.swift
//  CoreDataDemo
//
//  Created by Liis on 13.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class ContactTypeTableViewCell: UITableViewCell {
    

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var contactType: UILabel!
    @IBOutlet weak var details: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

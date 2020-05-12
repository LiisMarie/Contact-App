//
//  PersonTableViewCell.swift
//  CoreDataDemo
//
//  Created by Liis on 12.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var contactsCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

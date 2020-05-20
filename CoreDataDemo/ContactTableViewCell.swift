//
//  ContactTableViewCell.swift
//  CoreDataDemo
//
//  Created by Liis on 12.05.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

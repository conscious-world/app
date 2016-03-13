//
//  SettingCheckboxTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/12/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class SettingCheckboxTableViewCell: UITableViewCell {
    
    var labelString: String = ""{
        didSet{
            if let label = self.settingLabel{
                label.text = labelString
            }
        }
    }

    @IBOutlet weak var settingLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

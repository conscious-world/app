//
//  TimerSettingsTableViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class TimerSettingsTableViewController: UITableViewController {

    @IBOutlet weak var timePicker: TimePickerView!
    let settings = TimerSettings.getCurrentSettings()
    
    override func viewDidLoad() {
        timePicker.settings = settings
        timePicker.countDownDuration = settings.intervalSeconds
    }
   
}

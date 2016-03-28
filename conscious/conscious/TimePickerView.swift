//
//  TimePickerView.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/10/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class TimePickerView: UIDatePicker {

    var settings: TimerSettings?
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(TimePickerView.timePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func timePickerChanged(timePicker:UIDatePicker) {
        settings?.intervalSeconds = self.countDownDuration
    }
}

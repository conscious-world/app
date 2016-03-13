//
//  SimpleSelectableSetting.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/12/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation

struct SimpleSelectableSetting {
    var value: AnyObject?
    var label: String
    var type: TimerSettings.SettingType
    //callback method when setting is selected
    var onSelect: (_:AnyObject)->()?
    
    var selected: Bool = false{
        //allow something to happen on select, like playing the sound, or updating settings
        
        didSet{
            if(self.isInitialized && selected){
                onSelect(self.value!)
            }
        }
    }
    //flag so we dont run callback on select when initaliing the struct
    var isInitialized = false
    
    init(value:AnyObject, label: String, selected:Bool = false, type: TimerSettings.SettingType, onSelect: (_:AnyObject)->()?){
        self.value = value
        self.label = label
        self.type = type
        self.selected = selected
        self.onSelect = onSelect
        self.isInitialized = true
    }
    
}

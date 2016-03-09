//
//  TimerSettings.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation


enum AudioFeebackEffects {
    case Reverb
    case Delay
}

class TimerSettings{
    
    var intervalSeconds: Int = 300
    var reminderTone: String = "bell1"
    var backgroundSoundFile: String = ""
    var backgroundGif: String = "cloudssf"
    var AudioFeedback: AudioFeebackEffects? = nil
    
    init(){
    
    }
    
    func save(){
    
    }

}

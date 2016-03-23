//
//  TimerSettings.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation
import AVFoundation


class TimerSettings{
    
    enum SettingType{
        case ReminderTone
        case BackgroundSoundFile
    }
    
    var blockSave = false
    
    var intervalSeconds: Double = 600.0{
        didSet {
            self.save()
        }
    }
    
    var reminderTones = ["bowl", "bells"]
    var reminderTone: String = "none"{
        didSet {
            self.save()
        }
    }

    var backgroundSoundFiles = ["none", "crickets","waves", "rain"]
    var backgroundSoundFile: String = "rain"{
        didSet {
            self.save()
        }
    }

    var backgroundGif: String = "radialColors"{
        didSet {
            self.save()
        }
    }

    var audioEffect: String = "reverb"{
        didSet {
            self.save()
        }
    }
    
    func useAudioReverb() -> Bool{
        return audioEffect == "reverb"
    }

    var reminderAudioPlayer:AVAudioPlayer!
    var backgroundAudioPlayer:AVAudioPlayer!
    
    static let userTimerSettingsKey = "world.conscios.meditaion.TimerSettings"
        
    init(){
        settings = ["":""]
    }
    
    static func getCurrentSettings() -> TimerSettings{
        let userDefaultSettings = NSUserDefaults.standardUserDefaults()
        
        if let savedSettings = userDefaultSettings.valueForKey(TimerSettings.userTimerSettingsKey) as? [String:String]{
            let savedTimerSetting = TimerSettings()
            savedTimerSetting.settings = savedSettings
            return savedTimerSetting
        }
        //nothing saves so return the detault settings
        return TimerSettings()
    }
    
    
    func save(){
        if(!blockSave){
            let userDefaultSettings = NSUserDefaults.standardUserDefaults()
            userDefaultSettings.setObject(settings, forKey: TimerSettings.userTimerSettingsKey)
        }
    }
    
    var settings: [String:String]{
    
        set{
            self.blockSave = true
            if let newInterval = newValue["intervalSeconds"]{
                if let newIntervalDouble = Double(newInterval){
                    self.intervalSeconds = newIntervalDouble
                }
            }
            
            if let reminderTone = newValue["reminderTone"]{
                self.reminderTone = reminderTone
            }
            
            if let backgroundSoundFile = newValue["backgroundSoundFile"]{
                self.backgroundSoundFile = backgroundSoundFile
            }
            
            if let backgroundGif = newValue["backgroundGif"]{
                self.backgroundGif = backgroundGif
            }
            
            if let audioEffect = newValue["audioEffect"] {
                self.audioEffect = audioEffect
            }
            self.blockSave = false
        }
        
        get{
            var effect: String?
            return
            [
                "intervalSeconds":     String(intervalSeconds),
                "reminderTone":        reminderTone,
                "backgroundSoundFile": backgroundSoundFile,
                "backgroundGif":       backgroundGif,
                "audioEffect":         audioEffect,
            ]
        }
        
    }
    
    func playReminderTone(){
        let audioFilePath = NSBundle.mainBundle().pathForResource(self.reminderTone, ofType: "mp3")
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            do {
                
                reminderAudioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
                reminderAudioPlayer.volume = 0.5
                reminderAudioPlayer.play()
            }
            catch {
                fatalError ("Error loading \(audioFileUrl): \(error)")
            }
            
        } else {
            print("audio file is not found")
        }
    }
    
    func stopReminderTone(){
        reminderAudioPlayer?.stop()
    }
    
    func stopBackgroundSound(){
        backgroundAudioPlayer?.stop()
    }
    
    func playBackgroundSound(){
        let audioFilePath = NSBundle.mainBundle().pathForResource(backgroundSoundFile, ofType: "mp3")
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            do {
                
                backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
                backgroundAudioPlayer.volume = 0.2
                backgroundAudioPlayer.numberOfLoops = -1
                backgroundAudioPlayer.play()
            }
            catch {
                fatalError ("Error loading \(audioFileUrl): \(error)")
            }
            
        } else {
            print("audio file is not found")
        }
    }

}

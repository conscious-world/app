//
//  TimerSettings.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation
import AVFoundation


enum AudioFeebackEffects {
    case Reverb
    case Delay
}

class TimerSettings{
    
    var intervalSeconds: Int = 60
    var reminderTone: String = "bowl1hit"
    var backgroundSoundFile: String = "rain-06"
    var backgroundGif: String = "cloudssf"
    var AudioFeedback: AudioFeebackEffects? = nil
    var reminderAudioPlayer:AVAudioPlayer!
    var backgroundAudioPlayer:AVAudioPlayer!
    
    init(){
    
    }
    
    func save(){
    
    }
    
    func playReminderTone(){
        let audioFilePath = NSBundle.mainBundle().pathForResource(self.reminderTone, ofType: "wav")
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
    
    func stopBackgroundSound(){
        backgroundAudioPlayer.stop()
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

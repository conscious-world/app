//
//  Mediation.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/13/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation

class Meditation: NSObject, NSCoding{
    
    static let TYPE_KEY = "conscious.mediation.type"
    static let MEIDIA_ID_KEY = "conscious.mediation.media_id"
    static let MENTALITY_BEFORE_KEY = "conscious.mediation.mentality_before"
    static let MENTALITY_AFTER_KEY = "conscious.mediation.mentality_after"
    static let DURRATION_KEY = "conscious.mediation.durration"
    static let TIME_START_KEY = "conscious.mediation.time_start"
    static let TIME_END_KEY = "conscious.mediation.time_end"
    static let OPTIONS_KEY = "conscious.mediation.options"
    
    static let timed_mediation_type = "timed_meditation"
    static let guided_mediation_type = "guided_meditation"

    var meditation_type: String
    var meditation_title: String?
    var meditation_description: String?
    var coverImageUrl: String?
    var iconName: String?
    var media_id: String?
    var mentality_before: String?
    var mentality_after: String?
    var durration: NSTimeInterval?
    var time_start: NSDate?
    var time_end: NSDate?
    var options: [[String:String]]?
    var mediaName: String?
    
    var pathForMedia: String?{
        get{
            return NSBundle.mainBundle().pathForResource(self.mediaName, ofType: "mp3")!
        }
    }
    
    
    var coverImage: UIImage?{
        get{
            guard let imageName = self.coverImageUrl
                else{
                    return nil
            }
            return UIImage(named: imageName)
        }
    }
    
    
    init(meditation_type: String, media_id: String?, mentality_before: String?, mentality_after: String?, durration: NSTimeInterval?, time_start: NSDate?, time_end: NSDate?, options: [[String:String]]?){
        self.meditation_type    = meditation_type
        self.media_id           = media_id
        self.mentality_before   = mentality_before
        self.mentality_after    = mentality_after
        self.durration          = durration
        self.time_start         = time_start
        self.time_end           = time_end
        self.options            = options
    }
    
    required convenience init?(coder decoder: NSCoder){
        guard let meditation_type = decoder.decodeObjectForKey(Meditation.TYPE_KEY) as? String
        else{
            return nil
        }
        
        self.init(meditation_type: meditation_type,
            media_id:           decoder.decodeObjectForKey(Meditation.MEIDIA_ID_KEY) as? String,
            mentality_before:   decoder.decodeObjectForKey(Meditation.MENTALITY_BEFORE_KEY) as? String,
            mentality_after:    decoder.decodeObjectForKey(Meditation.MENTALITY_AFTER_KEY) as? String,
            durration:          decoder.decodeObjectForKey(Meditation.DURRATION_KEY) as? NSTimeInterval,
            time_start:         decoder.decodeObjectForKey(Meditation.TIME_START_KEY) as? NSDate,
            time_end:           decoder.decodeObjectForKey(Meditation.TIME_END_KEY) as? NSDate,
            options:            decoder.decodeObjectForKey(Meditation.OPTIONS_KEY) as? [[String:String]]
        )
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.meditation_type, forKey: Meditation.TYPE_KEY)
        coder.encodeObject(self.media_id, forKey: Meditation.MEIDIA_ID_KEY)
        coder.encodeObject(self.mentality_before, forKey: Meditation.MENTALITY_BEFORE_KEY)
        coder.encodeObject(self.mentality_after, forKey: Meditation.MENTALITY_AFTER_KEY)
        coder.encodeObject(self.durration, forKey: Meditation.DURRATION_KEY)
        coder.encodeObject(self.time_start, forKey: Meditation.TIME_START_KEY)
        coder.encodeObject(self.time_end, forKey: Meditation.TIME_END_KEY)
        coder.encodeObject(self.options, forKey: Meditation.OPTIONS_KEY)
    }
    
    static func newTimedMeditation() -> Meditation{
        let meditation = Meditation(meditation_type: Meditation.timed_mediation_type, media_id: nil, mentality_before: nil, mentality_after: nil, durration: nil, time_start: nil, time_end: nil, options: nil)
        //meditation.meditation_title = "Timed medation"
        return meditation
    }
    
    static func newGuidedMeditation() -> Meditation{
        return Meditation(meditation_type: Meditation.guided_mediation_type, media_id: nil, mentality_before: nil, mentality_after: nil, durration: nil, time_start: nil, time_end: nil, options: nil)
    }
    
    func start(){
        self.time_start = NSDate()
    }
    
    func end(){
        self.time_end = NSDate()
    }
    
    static func getAllPossible() -> [Meditation]{
        return [ThreeMinuteBreathingMeditation.build(),
            HealingMeditation.build(),
            FiveMintueBreathingMeditation.build()]
    }
    
    class FiveMintueBreathingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "guidedBeachMeditation"
            meditation.iconName = "circle-user-7"
            meditation.mediaName = "MARC5MinuteBreathing"
            meditation.meditation_title = "Five Minute breathing excersise"
            meditation.meditation_description = "Five minutes is all it takes to reset your day with this simple breathing exercise"
            return meditation
        }
    }
    
    class TimedMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newTimedMeditation()
            meditation.coverImageUrl = "indoorMeditator"
            meditation.iconName = "clock-stopwatch-7"
            meditation.mediaName = "MARC5MinuteBreathing"
            meditation.meditation_title = "Start a new timed meditation"
            meditation.meditation_description = "Set a timer, selection optional scene, background sound, reminder tone and audio chant reverb"
            return meditation
        }
    }
    

    
    class ThreeMinuteBreathingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "colors"
            meditation.iconName = "circle-user-7"
            meditation.mediaName = "3-Minute-Breathing-Space"
            meditation.meditation_title = "3 Minute Breathing Space"
            meditation.meditation_description = "Three minutes is all it takes to reset your day with this simple breathing exercise"
            return meditation
        }
    }
    
    class HealingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "maha-mrityunjaya"
            meditation.iconName = "circle-user-7"
            meditation.mediaName = "Hein-Braat-Maha-Mrityeonjaya-Mantra"
            meditation.meditation_title = "Hein Braat: Maha Mrityeonjaya Mantra"
            meditation.meditation_description = "Said to be beneficial for mental, emotional and physical health and to be a moksha mantra which bestows longevity and immortality."
            return meditation
        }
    }
}


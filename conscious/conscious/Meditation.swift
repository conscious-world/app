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
    static let VIDEO_NAME_KEY = "conscious.mediation.video_name"
    static let FAVORITED_KEY = "conscious.mediation.favorited"
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
    var video_name: String?
    var user_avatar_name: String?
    var favorited = false
    var isVRVideo = false
    
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
    
    
    init(meditation_type: String, media_id: String?, mentality_before: String?, mentality_after: String?, durration: NSTimeInterval?, time_start: NSDate?, time_end: NSDate?, video_name: String?, favorited: Bool, options: [[String:String]]?){
        self.meditation_type    = meditation_type
        self.media_id           = media_id
        self.mentality_before   = mentality_before
        self.mentality_after    = mentality_after
        self.durration          = durration
        self.time_start         = time_start
        self.time_end           = time_end
        self.video_name         = video_name
        self.favorited          = favorited
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
            video_name:         decoder.decodeObjectForKey(Meditation.VIDEO_NAME_KEY) as? String,
            favorited:          (decoder.decodeObjectForKey(Meditation.FAVORITED_KEY) as? Bool)!,
            

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
        coder.encodeObject(self.video_name, forKey: Meditation.VIDEO_NAME_KEY)
        coder.encodeObject(self.options, forKey: Meditation.OPTIONS_KEY)
    }
    
    static func newTimedMeditation() -> Meditation{
        let meditation = Meditation(meditation_type: Meditation.timed_mediation_type, media_id: nil, mentality_before: nil, mentality_after: nil, durration: nil, time_start: nil, time_end: nil, video_name: nil, favorited: false, options: nil)
        //meditation.meditation_title = "Timed medation"
        return meditation
    }
    
    static func newGuidedMeditation() -> Meditation{
        return Meditation(meditation_type: Meditation.guided_mediation_type, media_id: nil, mentality_before: nil, mentality_after: nil, durration: nil, time_start: nil, time_end: nil, video_name: nil, favorited: false, options: nil)
    }
    
    func start(){
        self.time_start = NSDate()
    }
    
    func end(){
        self.time_end = NSDate()
    }
    
    func inProgress() -> Bool{
        return (self.time_start != nil && self.time_end == nil)
    }
    
    func hasEnded() -> Bool{
        return (self.time_start != nil && self.time_end != nil)
    }
    
    func hasNotStarted() -> Bool{
        return (self.time_start == nil && self.time_end == nil)
    }
    
    static func getAllPossible() -> [Meditation]{
        return [
            DrCampbellIntro.build(),
            DrCampbellBodyScan.build(),
            SarahCruzPeaceSoundMeditation.build(),
            MindfullnessInstitueDecember.build(),
            LovingKindnessVRMeditation.build(),
            ThreeMinuteBreathingMeditation.build(),
            MindfullnessInstitueNovemer.build(),
            HealingMeditation.build(),
            FiveMintueBreathingMeditation.build(),
            MindfullnessInstitueOctober.build(),]
    }
    
    class FiveMintueBreathingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "guidedBeachMeditation"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "MARC5MinuteBreathing"
            meditation.meditation_title = "Five Minute breathing excersise"
            meditation.meditation_description = "Five minutes is all it takes to reset your day with this simple breathing exercise"
            meditation.video_name = "lights-sea-sparkling_bynqeb"
            return meditation
        }
    }
    
    class TimedMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newTimedMeditation()
            meditation.coverImageUrl = "indoorMeditator"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "MARC5MinuteBreathing"
            meditation.meditation_title = "Start a new timed meditation"
            meditation.meditation_description = "Set a timer, selection optional scene, background sound, reminder tone and audio chant reverb"
            return meditation
        }
    }
    
    class LovingKindnessVRMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newTimedMeditation()
            meditation.coverImageUrl = "lovingkindnessVRcover"
            meditation.iconName = "ic_3d_rotation_white_18pt"
            meditation.mediaName = "LovingKindness"
            meditation.meditation_title = "Paul Thormahlen: Loving Kindness Medations (VR)"
            meditation.meditation_description = ""
            meditation.isVRVideo = true
            meditation.user_avatar_name = "paulthorahlen"
            return meditation
        }
    }
    
    class ThreeMinuteBreathingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "colors"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "3-Minute-Breathing-Space"
            meditation.meditation_title = "3 Minute Breathing Space"
            meditation.meditation_description = "Three minutes is all it takes to reset your day with this simple breathing exercise"
            meditation.video_name = "heavenly-rays"

            return meditation
        }
    }
    
    class DrCampbellIntro: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "colors"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "DrCampbellBodyScan2"
            meditation.meditation_title = "Intro to meditation with Dr Colleen Cambell"
            meditation.meditation_description = "Three minutes is all it takes to reset your day with this simple breathing exercise"
            meditation.video_name = "heavenly-rays"
            meditation.user_avatar_name = "colleen"
            
            return meditation
        }
    }
    
    class DrCampbellBodyScan: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "colors"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "DrCampbellBodyScan2"
            meditation.meditation_title = "Dr Colleen Cambell - Ignite your potential: Full body scan"
            meditation.meditation_description = "Three minutes is all it takes to reset your day with this simple breathing exercise"
            meditation.video_name = "heavenly-rays"
            meditation.user_avatar_name = "colleen"
            
            return meditation
        }
    }
    
    class MindfullnessInstitueDecember: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "mindfulInstutiuteCover"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "MIDecemberMeditation"
            meditation.meditation_title = "Mindfulinstitue: December"
            meditation.meditation_description = ""
            meditation.video_name = "heavenly-rays"
            meditation.user_avatar_name = "lianna"
            
            return meditation
        }
    }
    
    
    class MindfullnessInstitueNovemer: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "mindfulInstutiuteCover"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "MINovemberMeditation"
            meditation.meditation_title = "Mindful Institue: November"
            meditation.meditation_description = ""
            meditation.video_name = "heavenly-rays"
            meditation.user_avatar_name = "lianna"
            
            return meditation
        }
    }
    
    class MindfullnessInstitueOctober: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "mindfulInstutiuteCover"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "MIOctoberMeditationTheMasksWeWear"
            meditation.meditation_title = "Mindful Institue: the masks we wear"
            meditation.meditation_description = ""
            meditation.video_name = "heavenly-rays"
            meditation.user_avatar_name = "lianna"
            
            return meditation
        }
    }
    
    class SarahCruzPeaceSoundMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "exampleMeditionCover"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "PeaceSoundMeditation"
            meditation.meditation_title = "Postures of Grace: Peace Sound Medation"
            meditation.meditation_description = ""
            meditation.video_name = "abstract-ocean-with-light-flares"
            meditation.user_avatar_name = "sarahcruz"
            return meditation
        }
    }
    
    class HealingMeditation: Meditation{
        static func build() -> Meditation{
            let meditation = Meditation.newGuidedMeditation()
            meditation.coverImageUrl = "maha-mrityunjaya"
            meditation.iconName = "ic_record_voice_over"
            meditation.mediaName = "Hein-Braat-Maha-Mrityeonjaya-Mantra"
            meditation.meditation_title = "Hein Braat: Maha Mrityeonjaya Mantra"
            meditation.meditation_description = "Said to be beneficial for mental, emotional and physical health and to be a moksha mantra which bestows longevity and immortality."
            meditation.video_name = "green-sky-in-space"
            return meditation
        }
    }
}


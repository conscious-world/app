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
    var media_id: String?
    var mentality_before: String?
    var mentality_after: String?
    var durration: NSTimeInterval?
    var time_start: NSDate?
    var time_end: NSDate?
    var options: [[String:String]]?
    
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
            media_id:           decoder.decodeObjectForKey("media_id") as? String,
            mentality_before:   decoder.decodeObjectForKey("mentality_before") as? String,
            mentality_after:    decoder.decodeObjectForKey("mentality_after") as? String,
            durration:          decoder.decodeObjectForKey("durration") as? NSTimeInterval,
            time_start:         decoder.decodeObjectForKey("time_start") as? NSDate,
            time_end:           decoder.decodeObjectForKey("time_end") as? NSDate,
            options:            decoder.decodeObjectForKey("options") as? [[String:String]]
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
        return Meditation(meditation_type: Meditation.timed_mediation_type, media_id: nil, mentality_before: nil, mentality_after: nil, durration: nil, time_start: nil, time_end: nil, options: nil)
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

}
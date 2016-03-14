//
//  History.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/6/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import Foundation


let HISTORY_KEY = "conscious.mediation.history"
class History: NSObject, NSCoding{
    
    private var meditations: [Meditation]?
    
    init(mediationHistory: [Meditation]?){
        if(mediationHistory != nil){
            self.meditations = mediationHistory
        }else{
            self.meditations = []
        }
    }

    required init?(coder aDecoder: NSCoder){
        print("decode meditations")
        self.meditations = aDecoder.decodeObjectForKey(HISTORY_KEY) as? [Meditation]
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        print("encode History.meditations")
        aCoder.encodeObject(self.meditations, forKey: HISTORY_KEY)
    }
    
    static func append(mediation:Meditation){
        sharedInstance()?.append(mediation)
    }
    
    static func sharedInstance() -> History?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.history
    }
    
    func append(mediation: Meditation){
        meditations!.append(mediation)
    }
    
    static func count() -> Int{
        return sharedInstance()?.count() ?? 0
    }
    
    func count() -> Int{
        return meditations?.count ?? 0
    }
    
    var first: Meditation?{
        return meditations?.first
    }
    
    var last: Meditation?{
        return meditations?.last
    }
}
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
    
    var mediations: [String: Meditation]
    
    init(mediationHistory: [String: Meditation]){
        self.mediations = mediationHistory
    }

    required init?(coder aDecoder: NSCoder){
        self.mediations = aDecoder.decodeObjectForKey(HISTORY_KEY) as! [String: Meditation]
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.mediations, forKey: HISTORY_KEY)
    }
}
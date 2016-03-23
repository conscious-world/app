//
//  ContributionHistoryView.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/22/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import TEAChart

class ContributionHistoryView: UIView, TEAContributionGraphDataSource {

    func monthForGraph() -> NSDate{
        return NSDate()
    }
    
    func  valueForDay(day: UInt ) -> Int{
        
        return 1
    }

}

//
//  ContributionStyleHistoryTableViewCell.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/22/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import TEAChart

class ContributionStyleHistoryTableViewCell: UITableViewCell, TEAContributionGraphDataSource {
    
    var contributionGraph: TEAContributionGraph?
    var mediationsDays: [Int] = [0]

    override func awakeFromNib() {
        super.awakeFromNib()
        let contributionGraph = TEAContributionGraph(frame: CGRectMake(50, 8, 282, 260))
        self.addSubview(contributionGraph)
        contributionGraph.showDayNumbers = true
        contributionGraph.delegate = self
        
        
        guard let history = History.sharedInstance() else{
            for day in 1...31{
                mediationsDays[day] = 0
            }
            return
        }
        
        for day in 1...31{
            mediationsDays.append(0)
            for mediation in history.meditations!{
                if let date = mediation.time_start{
                    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
                    let components = calendar.components([.Month, .Day], fromDate: date)
                    let (_, medDay) = (components.month, components.day)
                    

                    
                    if medDay == Int(day){
                        mediationsDays[day] = 1
                    }
                }
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func monthForGraph() -> NSDate{
        
        return NSDate()
    }

    func  valueForDay(day: UInt ) -> Int{
        return mediationsDays[Int(day)]
    }
    
    @objc(colorForGrade:)
    func colorForGrade(grade: UInt) -> UIColor{
        if(grade == 0){
            return UIColor.lightGrayColor()
        }
        else{
            return UIColor.loathingColor()
        }
    }

}

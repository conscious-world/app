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
    
     // Defines the number of distinct colors in the graph
//    @objc
//    override func numberOfGrades() -> UInt{
//        return 3
//    }
//    
//    
//    var originalColor: UIColor = UIColor(hexString: "#FAC54B")
//    let rageColor: UIColor = UIColor(hexString: "#f96c6c")
//    let fearColor: UIColor = UIColor(hexString: "#b2f96c")
//    var amazementColor: UIColor = UIColor(hexString: "#6cf9f9")
//    var loathingColor: UIColor = UIColor(hexString: "#b26cf9")
//    var joyColor: UIColor = UIColor(hexString: "#f4eb24")
//    // Defines what color should be used by each grade.
//    
//    @objc
//    override func colorForGrade(grade: UInt){
//        if(grade = 0)
//        {
//            return UIColor.whiteColor()
//        }
//        else if grade >= 1 && grade < 5{
//            
//            return amazementColor
//        }
//        else{
//            return rageColor
//        }
//
//    }
    
    // Defines the cutoff values used for translating values into grades.
    // For example, you may want different grades for the values grade == 0, 1 <= grade < 5, 5 <= grade.
    // This means there are three grades total
    // The minimumValue for the first grade is 0, the minimum for the second grade is 1, and the minimum for the third grade is 5
    //- (NSInteger)minimumValueForGrade:(NSUInteger)grade;

}

//
//  HistoryViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/26/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import Spring
import TEAChart
import Player

class HistoryViewController: UIViewController, TEAContributionGraphDataSource, PlayerDelegate {
    
    var contributionGraph: TEAContributionGraph?
    var mediationsDays: [Int] = [0]
    
    @IBOutlet weak var backgroundVideoContainer: UIView!
    
    let videoNames = ["heavenly-rays", "green-sky-in-space","abstract-ocean-with-light-flares", "lights-sea-sparkling_bynqeb", "stars-and-colors-in-space"]
    
    var player = Player()

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundVideo()
        let contributionGraph = TEAContributionGraph(frame: CGRectMake(50, 50, 282, 260))
        self.view.addSubview(contributionGraph)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.player.playFromBeginning()
        self.player.fillMode = AVLayerVideoGravityResizeAspectFill
    }
    
    func addBackgroundVideo(){
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        self.addChildViewController(player)
        self.backgroundVideoContainer.addSubview(player.view)
        self.player.didMoveToParentViewController(self)
        
        let urlpath = NSBundle.mainBundle().pathForResource(videoNames[2], ofType: "mp4")
        let videoUrl:NSURL = NSURL.fileURLWithPath(urlpath!)
        self.player.setUrl(videoUrl)
        
    }
    
    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
        player.playFromBeginning()
    }
    

    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

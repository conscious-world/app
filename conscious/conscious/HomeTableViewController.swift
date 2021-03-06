//
//  ViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import Spring
import TEAChart
import Player

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TEAContributionGraphDataSource, PlayerDelegate{
    
    let videoNames = ["heavenly-rays", "green-sky-in-space","abstract-ocean-with-light-flares", "lights-sea-sparkling_bynqeb", "stars-and-colors-in-space"]

    @IBOutlet weak var tableView: UITableView!

    
    var categories = ["Guided Meditations"]
    var histories = ["basics"]
    var ctas = ["intro"]
    var history: [String] = []
    var recomededMediations = ["PM Relaxations"]
    var tableSectionsData:[[String]] = []
    var meditations: [Meditation] = Meditation.getAllPossible()
    var ctaCell: CallToActionTableViewCell?
    var lastMeditaion: Meditation?
    var player = Player()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSectionsData = [ctas,recomededMediations]

        tableView.dataSource = self
        tableView.delegate = self
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
//        let layer = ctaCell?.ctaButton.layer
//        layer.animation = "squeezeDown"
//        layer.animate()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.player.playFromBeginning()
        self.player.fillMode = AVLayerVideoGravityResizeAspectFill
    }
    
    override func viewWillAppear(animated: Bool) {
        addBackgroundVideo()
        if let _lastMeditaion = History.sharedInstance()?.last{
            lastMeditaion = _lastMeditaion
            print("you have \(History.count()) medations and your last mediation was of type \(lastMeditaion?.meditation_type)" )
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            print("section = 0")
            return 1
        }

        return meditations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView \(tableSectionsData.count)")
        return tableSectionsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {

        case 0:
            ctaCell =  tableView.dequeueReusableCellWithIdentifier("CallToActionTableViewCell", forIndexPath: indexPath) as? CallToActionTableViewCell
            return ctaCell!
        case 1:
            print("render MediaTableViewCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath) as! MediaTableViewCell
            cell.meditation = meditations[indexPath.row]
            cell.navigationController = self.navigationController
            return cell
        default:
            print("In default")
            return tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath) as! MediaTableViewCell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPath.section == 0) ? 400 : 200
    }
    
    //there is no segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        if let cell = sender as? MediaTableViewCell, mediaController = destination as? MediaViewController{
            mediaController.meditation = cell.meditation
        }
    }


    @IBOutlet weak var logoImageHeightConstraint: NSLayoutConstraint!
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }
        
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.ctaCell?.resizeLogo(200.0 - scrollView.contentOffset.y)
        
        if(scrollView.contentOffset.y < 0){
            self.ctaCell?.resizeHeader(300.0 + abs(scrollView.contentOffset.y))
        }

    }
    
    func monthForGraph() -> NSDate{
        return NSDate()
    }
    
    func  valueForDay(day: UInt ) -> Int{
        
        return Int(day) % 6;
    }
    
    func addBackgroundVideo(){

        if let tableCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? CallToActionTableViewCell{
            
            tableCell.backgroundColor = UIColor.clearColor()
            tableCell.contentView.backgroundColor = UIColor.clearColor()
            self.tableView.backgroundColor = UIColor.clearColor()
            self.player.delegate = self
            self.player.view.frame = self.view.bounds
            self.addChildViewController(player)
            
            self.view.addSubview(player.view)
            self.view.sendSubviewToBack(player.view)
            self.player.didMoveToParentViewController(self)
            
            let urlpath = NSBundle.mainBundle().pathForResource(videoNames[2], ofType: "mp4")
            let videoUrl:NSURL = NSURL.fileURLWithPath(urlpath!)
            self.player.setUrl(videoUrl)
        
        }

        
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

}



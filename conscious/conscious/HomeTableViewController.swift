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

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TEAContributionGraphDataSource {

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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSectionsData = [ctas,history,recomededMediations]
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        
//        let layer = ctaCell?.ctaButton.layer
//        layer.animation = "squeezeDown"
//        layer.animate()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let _lastMeditaion = History.sharedInstance()?.last{
            lastMeditaion = _lastMeditaion
            if(history.count < 1){
                print("Inserty a history item")
                history.append(_lastMeditaion.meditation_type)
                tableSectionsData.insert(history, atIndex: 1)
            }
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
        if section == 1{
            print("section = 1")
            return history.count < 1 ? 0 : 1
        }
        print("section = 2")
        return meditations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSectionsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {

        case 0:
            ctaCell =  tableView.dequeueReusableCellWithIdentifier("CallToActionTableViewCell", forIndexPath: indexPath) as? CallToActionTableViewCell
            return ctaCell!
            
        case 1:
            print("render ContributionStyleHistoryTableViewCell")
            let cell =  tableView.dequeueReusableCellWithIdentifier("ContributionStyleHistoryTableViewCell", forIndexPath: indexPath) as! ContributionStyleHistoryTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath) as! MediaTableViewCell
            cell.meditation = meditations[indexPath.row]
            cell.navigationController = self.navigationController
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath) as! MediaTableViewCell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250.0
    }
    
    //there is no segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        print("destination controller = \(sender.self)")
        if let cell = sender as? MediaTableViewCell, mediaController = destination as? MediaViewController{
            print("sender.self")
            mediaController.meditation = cell.meditation
        }
        //destination.transitioningDelegate = self
    }


    @IBOutlet weak var logoImageHeightConstraint: NSLayoutConstraint!
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        //self.blurEffectView.alpha = 0
    }
        
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.y)
        
        self.ctaCell?.resizeLogo(200.0 - scrollView.contentOffset.y)
        
        if(scrollView.contentOffset.y < 0){
            print("self.ctaCell?.resizeHeader NOW")
            self.ctaCell?.resizeHeader(250.0 + abs(scrollView.contentOffset.y))
        }

    }
    
    func monthForGraph() -> NSDate{
        return NSDate()
    }
    
    func  valueForDay(day: UInt ) -> Int{
        
        return Int(day) % 6;
    }

}



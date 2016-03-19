//
//  ViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit
import StarWars

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var categories = ["Guided Meditations"]
    var histories = ["basics"]
    var ctas = ["intro"]
    var recomededMediations = ["PM Relaxations"]
    var tableSectionsData:[[String]] = []
    var meditations: [Meditation] = Meditation.getAllPossible()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSectionsData = [ctas,recomededMediations]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        let lastMeditaion = History.sharedInstance()?.last
        print("you have \(History.count()) medations and your last mediation was of type \(lastMeditaion?.meditation_type)" )
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
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
//        case 0:
//            let cell = tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath)      as! HistoryTableViewCell
//            cell.meditationCountLabel.text = "\(History.count())"
//            return cell
        case 0:
            let  cell =  tableView.dequeueReusableCellWithIdentifier("CallToActionTableViewCell", forIndexPath: indexPath) as! CallToActionTableViewCell
            cell.navigationController = self.navigationController
            return cell
            
//        case 1:
//            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryTableViewCell", forIndexPath: indexPath)     as! CategoryTableViewCell
//            cell.navigationController = self.navigationController
//            return cell
//            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath)        as! MediaTableViewCell
            cell.meditation = meditations[indexPath.row]
            cell.navigationController = self.navigationController
            return cell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath) as! MediaTableViewCell
        }
        
    }
    
    //there is no segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController
        destination.transitioningDelegate = self
    }

}

extension HomeTableViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return StarWarsGLAnimator()
        
    }
}


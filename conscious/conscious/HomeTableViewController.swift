//
//  ViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var categories = ["Timed Meditation", "Guided Meditations", "Ambient Sounds", "Chants", "Binaural Beats"]
    var histories = ["basics"]
    var ctas = ["intro"]
    var recomededMediations = ["Loving Kindness", "Healing", "PM Relaxations"]
    var tableSectionsData:[[String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSectionsData = [histories, ctas, categories, recomededMediations]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSectionsData[section].count
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
            return tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath)      as! HistoryTableViewCell
        case 1:
            var cell =  tableView.dequeueReusableCellWithIdentifier("CallToActionTableViewCell", forIndexPath: indexPath) as! CallToActionTableViewCell
            cell.navigationController = self.navigationController
            return cell
        case 2:
            return tableView.dequeueReusableCellWithIdentifier("CategoryTableViewCell", forIndexPath: indexPath)     as! CategoryTableViewCell
        case 3:
            return tableView.dequeueReusableCellWithIdentifier("MediaTableViewCell", forIndexPath: indexPath)        as! MediaTableViewCell
        default:
            return tableView.dequeueReusableCellWithIdentifier("CallToActionTableViewCell", forIndexPath: indexPath) as! CallToActionTableViewCell
        }
        
    }


}


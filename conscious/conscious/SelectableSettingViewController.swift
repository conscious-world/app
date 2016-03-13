//
//  SelectableSettingViewController.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/12/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

protocol SelectableSettingViewControllerDelegate : class {
    func settingSelected(controller: SelectableSettingViewController, setting: AnyObject, type: TimerSettings.SettingType)
}


class SelectableSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var settings: [SimpleSelectableSetting]?
    
    var delegate: SelectableSettingViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onDoneButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion:{
            //do we need to save?
            print("dismiss")
        })

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingCheckboxTableViewCell", forIndexPath: indexPath) as! SettingCheckboxTableViewCell
        let setting = settings![indexPath.row]
        cell.labelString = setting.label
        
        if (setting.selected)
        {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.delegate?.settingSelected(self, setting: setting.value!, type: setting.type)
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings != nil ? settings!.count : 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        for index in 0...(settings!.count - 1){
            settings![index].selected = false
        }
        settings![indexPath.row].selected = true
        tableView.reloadData()
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

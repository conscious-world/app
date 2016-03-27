//
//  AppDelegate.swift
//  conscious
//
//  Created by Paul Thormahlen on 3/2/16.
//  Copyright © 2016 Conscious World. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var history: History?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let s = pathForKeyArchive
        NSLog("String: \(s)")
        print("didFinishLaunchingWithOptions")
        
        
        self.history = self.historyFromDisk()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("applicationDidEnterBackground")
        self.saveToDisk()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    private func historyFromDisk() -> History?{
        print("historyFromDisk")
        if let meditations = NSKeyedUnarchiver.unarchiveObjectWithFile(pathForKeyArchive) as? [Meditation]{
            
            print("got history from disk")
            return History(mediationHistory: meditations)
        }
        print("no history from disk so just returnting a new history object")

        return History(mediationHistory: nil)
    }
    
    private func saveToDisk(){
        print("saveToDisk")
        if let historyToSave = self.history{
            print("we have history")
            if let medations = historyToSave.meditations{
                print("we have mediations so archiveRootObject \(medations) to \(pathForKeyArchive)")
                let result = NSKeyedArchiver.archiveRootObject(medations, toFile: pathForKeyArchive)
                print("NSKeyedArchiver.archiveRootObject\(medations) returned \(result)")
            }
            
        }
    }
    
    private var pathForKeyArchive:String{
        return (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString).stringByAppendingPathComponent("history.bin")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        let s = pathForKeyArchive
        NSLog("String: \(s)")
        print("applicationDidBecomeActive")
        self.history = self.historyFromDisk()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveToDisk()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


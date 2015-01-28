//
//  MenuViewController.swift
//  AirbnbViewController-Sample
//
//  Created by pixyzehn on 1/27/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class MenuViewController: AirbnbViewController, AirbnbMenuDelegate, AirbnbMenuDataSource {
    
    var sessionArray: [[String]] = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
        
        let session1: [String] = ["air_root", "segue1"]
        let session2: [String] = ["segue2", "segue3"]
        
        self.sessionArray = [session1, session2]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // AirbnbMenuDelegate

    override func numberOfSession() -> Int {
        return sessionArray.count
    }
    
    override func numberOfRowsInSession(session: Int) -> Int {
        return sessionArray[session].count
    }
    
    override func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        return "Row \(indexPath.row) in \(indexPath.section)"
    }
    
    override func titleForHeaderAtSession(session: Int) -> String {
        return "Session \(session)"
    }
    
    override func segueForAtIndexPath(indexPath: NSIndexPath) -> String {
        //return sessionArray[indexPath.section][indexPath.row]
        return ""
    }
    
    func didSelectRowAtIndex(indexPath: NSIndexPath) {
    }
    
    func viewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController {
        let viewController: ViewController = ViewController()
        
        let controller: UINavigationController = UINavigationController(rootViewController: viewController)
        
        switch indexPath.row {
        case 0:
            viewController.view.backgroundColor = UIColor(red:0.13, green:0.14, blue:0.15, alpha:1)
        case 1:
            viewController.view.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
        case 2:
            viewController.view.backgroundColor = UIColor(red:0.8, green:0, blue:0.48, alpha:1)
        default:
            break
        }
        return controller
    }
}

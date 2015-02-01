//
//  ViewController.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class MenuViewController: AirbnbViewController, AirbnbMenuDelegate, AirbnbMenuDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }

    // AirbnbMenuDelegate
    
    func didSelectRowAtIndex(indexPath: NSIndexPath) {
        println("you select \(indexPath.row) in \(indexPath.section)")
    }
    
    func willShowAirViewController() {
        println("willShowAirViewController")
    }
    
    func willHideAirViewController() {
        println("willHideAirViewController")
    }
    
    func didHideAirViewController() {
        println("didHideAirViewController")
    }
    
    func heightForAirMenuRow() -> CGFloat {
        return 60.0
    }
    
    // AirbnbDatasource

    override func numberOfSession() -> Int {
        return 4
    }
    
    override func numberOfRowsInSession(session: Int) -> Int {
        return 3
    }
    
    override func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        return "Row \(indexPath.row) in \(indexPath.section)"
    }
    
    override func titleForHeaderAtSession(session: Int) -> String {
        return "Session \(session)"
    }
    
    func thumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        return nil
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


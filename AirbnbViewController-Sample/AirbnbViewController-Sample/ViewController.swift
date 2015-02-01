//
//  ViewController.swift
//  AirbnbViewController-Sample
//
//  Created by pixyzehn on 1/27/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.blackColor()
        
        var button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 50, 35)
        button.setTitle("Menu", forState: UIControlState.Normal)
        button.setTitleColor(UIColor(red:0.3, green:0.69, blue:0.75, alpha:1), forState: UIControlState.Normal)
        button.addTarget(self, action: "leftButtonTouch", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        self.airSwipeHandler = {() -> Void in
            self.airViewController?.showAirViewFromViewController(self.navigationController, complete: nil)
            return
        }
    }
    
    func leftButtonTouch() {
        self.airViewController?.showAirViewFromViewController(self.navigationController, complete: nil)
    }
}


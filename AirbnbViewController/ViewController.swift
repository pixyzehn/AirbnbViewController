//
//  View1Controller.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/18/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
       
        self.view.backgroundColor = UIColor.blackColor()
        
        var button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 50, 35)
        button.setTitle("Menu", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        button.addTarget(self, action: "leftButtonTouch", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
       
        var bh: BlockHandler? = {() -> Void in
            self.airViewController?.showAirViewFromViewController(self.navigationController, complete: nil)
            return
        }
        self.abSwipeHandler = bh
        
//        self.abSwipeHandler = {() -> () in
//            self.airViewController?.showAirViewFromViewController(self.navigationController, complete: nil)
//            return
//        }
    }

    func leftButtonTouch() {
        self.airViewController?.showAirViewFromViewController(self.navigationController, complete: nil)
    }
    
    var _label: UILabel?
    var label: UILabel? {
        // readonly
        get {
            if _label == nil {
                _label = UILabel(frame: CGRectMake(0, 80, 320, 40))
                _label?.backgroundColor = UIColor.clearColor()
                _label?.textAlignment = NSTextAlignment.Center
                _label?.font = UIFont.boldSystemFontOfSize(16)
                _label?.textColor = UIColor.redColor()
                self.view.addSubview(_label!)
            }
            return nil
        }
        set {
            _label = newValue
        }
    }
    
}

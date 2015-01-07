//
//  AirbnbViewController.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

/*
view structer
-----------------
view
    ---------------
    wrapperView
    ---------------
        contentView
        -------------
            leftView
            -----------
                sessionView
                ---------
                title
                ---------
                button
            -------------
            rightView
            ---------
                airImageView
*/


import Foundation
import UIKit

let PHSegueRootIdentifier: String  = "phair_root"

@objc protocol AirbnbMenuDelegate: NSObjectProtocol {
    optional func shouldSelectRowAtIndex(indexPath: NSIndexPath) -> Bool
    optional func didSelectRowAtIndex(indexPath: NSIndexPath)
    optional func willShowAirViewController()
    optional func willHideAirViewController()
    optional func didHideAirViewController()
    optional func heightForAirMenuRow() -> Float
    optional func indexPathDefaultValue(indexPath: NSIndexPath)
}

@objc protocol AirbnbMenuDataSource: NSObjectProtocol {
    func numberOfSession() -> Int
    func numberOfRowsInSession(sesion: Int) -> Int
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String
    func titleForHeaderAtSession(session: Int) -> String
    optional func thumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage
    optional func viewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController
}

class AirbnbViewController: UIViewController, AirbnbMenuDelegate, AirbnbMenuDataSource , UIGestureRecognizerDelegate {
    
    var titleNormalColor: UIColor?
    var titleHighlightColor: UIColor?
    var delegate: AirbnbMenuDelegate?
    var dataSource: AirbnbMenuDataSource?
    var fontViewController: UIViewController?
    var currentIndexPath: NSIndexPath?
    
    let comlete = ({ () -> Void in })
   
    var wrapperView: UIView?
    var contentView: UIView?
    var leftView: UIView?
    var rightView: UIView?
    var airImageView: UIView?
    
    var lastDeegreesRotateTransform: CGFloat?
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    // number of data
    var session: Int?
    var rowsOfSession: [Int]?
    
    // sesion view
    var sessionViews: Dictionary<Int, UIView>?
    
    // current index sesion view
    var currentIndexSession: Int?
    
    // for animation
    var isAnimation: Bool?
    var topSession: AirbnbSessionView?
    var middleSession: AirbnbSessionView?
    var bottomSession: AirbnbSessionView?
    
    var lastIndexInSession: Dictionary<Int, AirbnbSessionView>?
    var thumbnailImages: [UIImage]?
    var viewControllers: [UIViewController]?
    var heightAirMenuRow: CGFloat?
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(viewController: UIViewController, atIndexPath:NSIndexPath) {
        self.init()
        let rect = UIScreen.mainScreen().applicationFrame
        self.view.frame = CGRectMake(0, 0, rect.width, rect.height)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.edgesForExtendedLayout != UIRectEdge.None {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        // Init sessionViews
        self.sessionViews = Dictionary<Int, AirbnbSessionView>()
        self.currentIndexSession = 0
        
        self.lastIndexInSession = Dictionary<Int, AirbnbSessionView>()
        //self.lastIndexInSession[0] = nil
        self.currentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        self.delegate = self
        self.dataSource = self
        
        // Init contentView
        self.view.addSubview(self.wrapperView!)
        self.wrapperView?.addSubview(self.contentView!)
        
        // Init left/rightView
        self.contentView?.addSubview(self.leftView!)
        self.contentView?.addSubview(self.rightView!)
        
        // Init airImageView
        self.rightView?.addSubview(self.airImageView!)
        
        // Setting color
        self.titleNormalColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
        self.titleHighlightColor = UIColor.blackColor()
        
        if let st = self.storyboard {
            self.performSegueWithIdentifier(PHSegueRootIdentifier, sender: nil)
        }
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeOnAirImageView:")
        swipe.direction = UISwipeGestureRecognizerDirection.Left
        self.airImageView?.addGestureRecognizer(swipe)
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleRevealGesture:")
        self.panGestureRecognizer?.delegate = self
        self.leftView?.addGestureRecognizer(self.panGestureRecognizer!)
        
        // Setup animation
        self.setupAnimation()
        
        self.leftView?.alpha = 0
        self.rightView?.alpha = 0
        
        // Default height row value
        self.heightAirMenuRow = 44
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    func bringViewControllerToTop(controller: UIViewController, indexPath: NSIndexPath) {
        if (controller == nil) {
            return
        }
        
        
    }
    
    func setupAnimation() {
        
    }
    
    func reloadData() {
        
    }
    
    func showAirViewFromViewController(controller: UIViewController, complete: () -> Void ) {
        
    }
    
    func switchToViewController(controller: UIViewController, atIndexPath: NSIndexPath) {
        
    }
    
    func switchToViewController(controller: UIViewController) {
        
    }
    
    // AirbnbMenuDelegate
    
    func shouldSelectRowAtIndex(indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func didSelectRowAtIndex(indexPath: NSIndexPath) {
        
    }
    
    // AirbnbMenuDataSource
    
    func numberOfSession() -> Int {
        
        return 2
    }
    
    func numberOfRowsInSession(sesion: Int) -> Int {
        
        return 2
    }
    
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        
        return "hoge"
    }
    
    func titleForHeaderAtSession(session: Int) -> String {
        
        return "hoge"
    }
    
}

extension UIViewController {
    /*
    var airbnbViewSwipeGestureRecognizer: UISwipeGestureRecognizer {
        return
    }
    var aribnbViewSwipeHander {
        return ({ () -> Void in })
    }
    
    func airViewController() -> AirbnbViewController {

    }
    */
}

// AirbnbViewControllerSegue

class PHAirViewControllerSegue: UIStoryboardSegue {
    
}

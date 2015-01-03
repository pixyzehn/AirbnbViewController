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
    
    let titleNormalColor: UIColor?
    let titleHighlightColor: UIColor?
    var delegate: AirbnbMenuDelegate?
    var dataSource: AirbnbMenuDataSource?
    var fontViewController: UIViewController?
    var currentIndexPath: NSIndexPath?
    
    let comlete = ({ () -> Void in })
    
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
    
    var lastIndexInSession: Dictionary<Int, UIView>?
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

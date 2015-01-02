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

    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(viewController: UIViewController, atIndexPath:NSIndexPath) {
        self.init()
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

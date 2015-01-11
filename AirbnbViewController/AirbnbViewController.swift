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

let kMenuItemHeight = 80
let kSessionWidth = 220

let kLeftViewTransX = -50
let kLeftViewRotate = -5
let kAirImageViewRotate = -25
let kRightViewTransX = 180
let kRightViewTransZ = -150

let kAirImageViewRotateMax = -42

let kDuration = 0.2

let kIndexPathOutMenu = NSIndexPath(forRow: 999, inSection: 0)

var AirDegreesToRadians = {(degrees: CGFloat) -> CGFloat in
    return degrees * CGFloat(M_PI) / 180.0
}

var AirRadiansToDegrees = {(radians: CGFloat) -> CGFloat in
    return radians * 180 / CGFloat(M_PI)
}

let PHSegueRootIdentifier = "phair_root"

class AirbnbViewController: UIViewController, AirbnbMenuDelegate, AirbnbMenuDataSource , UIGestureRecognizerDelegate {
    
    var titleNormalColor: UIColor?
    var titleHighlightColor: UIColor?
    
    var delegate: AirbnbMenuDelegate?
    var dataSource: AirbnbMenuDataSource?
    
    var fontViewController: UIViewController?
    var currentIndexPath: NSIndexPath?
    
    let comlete = ({ () -> Void in })
   
    // private property
    
    private var wrapperView: UIView?
    private var contentView: UIView?
    private var leftView: UIView?
    private var rightView: UIView?
    private var airImageView: UIView?
    
    private var lastDeegreesRotateTransform: CGFloat?
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
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
    /* [ // session 0
    {0 : thumbnail image 0,1 : thumbnail image 1},
    // session 1
    {0 : thumbnail image 0,1 : thumbnail image 1},
    ]
    */

    var thumbnailImages: [UIImage]?
    /* [ // session 0
    {0 : view controller 0,1 : view controller 1},
    // session 1
    {0 : view controller 0,1 : view controller 1},
    ]
    */

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
    
    func bringViewControllerToTop(controller: UIViewController?, indexPath: NSIndexPath?) {
        if (controller == nil) {
            return
        }
        
        self.fontViewController?.removeFromParentViewController()
        self.fontViewController?.view.removeFromSuperview()
        
        self.fontViewController = controller
        self.currentIndexPath = indexPath
        
        if (indexPath? != nil && indexPath?.row != kIndexPathOutMenu.row) {
            //self.lastIndexInSession[indexPath?.section] = indexPath?.row
            
            
        }
    }
    
    // storyboard support
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // ContentView
    
    func contentViewDidTap(recognizer: UITapGestureRecognizer) {
        
    }
    
    // Gesture Delegate

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // AirImageView gesture
    
    func handleSwipeOnAirImageView(swipe: UISwipeGestureRecognizer) {
        
    }
    
    func handleTapOnAirImageView(swipe: UISwipeGestureRecognizer) {
        
    }
    
    // Gesture Based Reveal
    
    func handleRevealGesture(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleRevealGestureStateBeganWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleRevealGestureStateChangedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleRevealGestureStateEndedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleRevealGestureStateCancelledWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    //
    
    func nextSession() {
        
    }
    
    func prevSession() {
        
    }
    
    func slideCurrentSession() {
        
    }
    
    func rotateAirImage() {
        
    }
    
    // layout menu
    
    func reloadData() {
        
    }
    
    func layoutContaintView() {
        
    }
    
    func updateButtonColor() {
        
    }
    
    // PHAirMenuDelegate
    
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
    
    // Button action
    
    func sessionButtonTouch(buttton: UIButton) {
        
    }
    
    func rowDidTouch(button: UIButton) {
        
    }
    
    // property
    
    // getter, setter
    
    // Show/Hide air view controller
    
    func showAirViewFromViewController(controller: UIViewController, complete: () -> Void ) {
        
    }
    
    func switchToViewController(controller: UIViewController, atIndexPath: NSIndexPath) {
        
    }
    
    func switchToViewController(controller: UIViewController) {
        
    }
    
    func hideAirViewOnComplete(complete: () -> Void) {
        
    }

    // animation
    
    func setupAnimation() {
        
    }
    
    // Helper
    
    func getThumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        
        return nil
    }
    
    func saveThumbnailImage(image: UIImage, atIndexPath indexPath: NSIndexPath) {
        
    }
    
    func getViewControllerAtIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        return nil
    }
    
    func saveViewControler(controller: UIViewController, atIndexPath indexPath: NSIndexPath) {
        
    }
    
    func imageWithView(image: UIImage) -> UIImage? {
        return nil
    }
    
    func duplicate(image: UIImage) -> UIImage? {
        return nil
    }
    
    deinit {
        
    }
}

let SwipeTagHandle = "SWIPE_HANDER"
let SwipeObject = "SWIPE_OBJECT"

extension UIViewController {
    
    func phSwipeGestureRecognizer() -> UISwipeGestureRecognizer? {
        return nil
    }
    
    func setPhSwipeHander(() -> Void) {
        
    }
    
    func phSwipeHander() -> (() -> Void)? {
        return nil
    }
    
    func swipeHanle() {
        
    }
    
    func airViewController() -> AirbnbViewController? {
        return nil
    }
    
}

    // AirViewControllerSegue Class

class PHAirViewControllerSegue: UIStoryboardSegue {
    
    var peformHandler = {(segue: PHAirViewControllerSegue, svc: UIViewController, dvc: UIViewController) -> Void in
        
    }
    
}

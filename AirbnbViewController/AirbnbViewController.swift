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
    optional func indexPathDefaultValue() -> NSIndexPath?
}

@objc protocol AirbnbMenuDataSource: NSObjectProtocol {
    func numberOfSession() -> Int
    func numberOfRowsInSession(sesion: Int) -> Int
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String
    func titleForHeaderAtSession(session: Int) -> String
    optional func thumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage
    optional func segueForAtIndexPath(indexPath: NSIndexPath) -> String
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

let kHeaderTitleHeight: CGFloat = 80

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
    
    var _wrapperView: UIView = UIView(frame: CGRectZero)
    private var wrapperView: UIView? {
        get {
            if self.wrapperView == nil {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                return view
            } else {
                return self.wrapperView
            }
        }
        set {
            self.wrapperView = newValue!
        }
    }
    private var contentView: UIView? {
        get {
            if self.contentView == nil {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                return view
            } else {
                return self.contentView
            }
        }
        set {
            self.contentView = newValue!
        }
    }
    private var leftView: UIView? {
        get {
            if self.leftView == nil {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                return view
            } else {
                return self.leftView
            }
        }
        set {
            self.leftView = newValue!
        }
    }
    private var rightView: UIView? {
        get {
            if self.rightView == nil {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                view.userInteractionEnabled = true
                return view
            } else {
                return self.rightView
            }
        }
        set {
            self.rightView = newValue!
        }
    }
    private var airImageView: UIImageView? {
        get {
            if self.airImageView == nil {
                let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.width, self.view.width))
                imageView.userInteractionEnabled = true
                return imageView
            } else {
                return self.airImageView
            }
        }
        set {
            self.airImageView = newValue!
        }
    }
    
    private var lastDeegreesRotateTransform: CGFloat?
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    // number of data
    var session: Int?
    var rowsOfSession: [Int]?
    
    // sesion view
    var sessionViews: Dictionary<Int, AirbnbSessionView>?
    
    // current index sesion view
    var currentIndexSession: Int?
    
    // for animation
    var isAnimation: Bool?
    var topSession: AirbnbSessionView?
    var middleSession: AirbnbSessionView?
    var bottomSession: AirbnbSessionView?
    
    var lastIndexInSession: Dictionary<Int, Int>?
    
    
    /* [ // session 0
    {0 : thumbnail image 0,1 : thumbnail image 1},
    // session 1
    {0 : thumbnail image 0,1 : thumbnail image 1},
    ]
    */
    var thumbnailImages: [Dictionary<Int, UIView>]?
    

    /* [ // session 0
    {0 : view controller 0,1 : view controller 1},
    // session 1
    {0 : view controller 0,1 : view controller 1},
    ]
    */
    var viewControllers: [Dictionary<Int, UIViewController>]?
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
        
        self.lastIndexInSession = Dictionary<Int, Int>()
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
            self.saveViewControler(controller!, atIndexPath: indexPath!)
        }
        
        self.addChildViewController(self.fontViewController!)
        let controllerView: UIView = self.fontViewController!.view
        controllerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        controllerView.frame = self.view.bounds
        self.view.addSubview(controllerView)
        self.fontViewController?.didMoveToParentViewController(self)
    }
    
    // storyboard support
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue is AirViewControllerSegue && sender? == nil {
            var nextIndexPath: NSIndexPath = self.currentIndexPath!
            if segue?.identifier == PHSegueRootIdentifier {
                if self.delegate != nil && self.delegate?.respondsToSelector("indexPathDefaultValue") != nil {
                    //nextIndexPath = self.delegate.indexPathDefaultValue()??
                }
            }
            var segu: AirViewControllerSegue = segue? as AirViewControllerSegue
            segu.peformHandler = {(rvc_segue: AirViewControllerSegue, svc: UIViewController, dvc: UIViewController) -> Void in
                self.bringViewControllerToTop(dvc, indexPath: nextIndexPath)
            }
        }
    }
    
    // ContentView
    
    func contentViewDidTap(recognizer: UITapGestureRecognizer) {
        if self.airImageView?.tag == 1 {
            
        }
    }
    
    // Gesture Delegate

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isAnimation == false {
            return false
        }
        return true
    }
    
    // AirImageView gesture
    
    func handleSwipeOnAirImageView(swipe: UISwipeGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.fontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    func handleTapOnAirImageView(swipe: UISwipeGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.fontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    // Gesture Based Reveal
    
    func handleRevealGesture(recognizer: UIPanGestureRecognizer) {
        if self.sessionViews?.count == 0 && self.sessionViews?.count == 1 {
            return
        }
        
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            self.handleRevealGestureStateBeganWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Changed:
            self.handleRevealGestureStateChangedWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Ended:
            self.handleRevealGestureStateEndedWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Cancelled:
            self.handleRevealGestureStateCancelledWithRecognizer(recognizer)
            break
        default:
            break
        }
    }
    
    func handleRevealGestureStateBeganWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleRevealGestureStateChangedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        let translation: CGFloat = recognizer.translationInView(self.leftView!).y
        self.leftView!.top = -(self.view.height - kHeaderTitleHeight) + translation
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let sessionViewHeight: Int = Int(self.view.height - kHeaderTitleHeight)
        var distanceScroll: Int = 0
        
        if afterTop - firstTop > 0 {
            let topMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight + 40
            if topMiddleSessionView < Int(self.view.height/2) {
                distanceScroll = Int(self.view.height/2) - topMiddleSessionView
                
            } else {
                distanceScroll = topMiddleSessionView - Int(self.view.height/2) + 40
            }
        } else {
            let bottomMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight*2
            if bottomMiddleSessionView > Int(self.view.height/2) {
                distanceScroll = bottomMiddleSessionView - Int(self.view.height/2)
            } else {
                distanceScroll = Int(self.view.height/2) - bottomMiddleSessionView
            }
        }
        
        distanceScroll = abs(Int(self.view.height/2) - distanceScroll)
        
        let rotateDegress: CGFloat = CGFloat(distanceScroll * abs(kAirImageViewRotateMax - kAirImageViewRotate))/(self.view.height/2)
        self.lastDeegreesRotateTransform = rotateDegress
        var airImageRotate: CATransform3D = CATransform3DIdentity
        airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(CGFloat(kAirImageViewRotate)-rotateDegress), 0, 1, 0)
        
        self.airImageView?.layer.transform = airImageRotate
    }
    
    func handleRevealGestureStateEndedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
        if sessionViews?.count == 0 {
            return
        }
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let velocity: CGPoint = recognizer.velocityInView(recognizer.view)
        
        if afterTop - firstTop > 0 {
            if afterTop - firstTop > Int(self.view.height/2) - 40 || abs(velocity.y) > 100 {
                self.prevSession()
            } else {
                self.slideCurrentSession()
            }
        } else {
            if firstTop - afterTop > Int(self.view.height/2) - 40 || abs(velocity.y) > 100 {
                self.nextSession()
            } else {
                self.slideCurrentSession()
            }
        }
    }
    
    func handleRevealGestureStateCancelledWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
    }
    
    //
    
    func nextSession() {
        
        self.currentIndexSession!++
        if self.currentIndexSession > self.sessionViews?.count {
            self.currentIndexSession = 0
        }
        
        // Get thumbnailImage
        let lastIndexInThisSession: NSIndexPath = NSIndexPath(forRow: self.lastIndexInSession![self.currentIndexSession!]!, inSection: self.currentIndexSession!)
        
        let nextThumbnail: UIImage? = self.getThumbnailImageAtIndexPath(lastIndexInThisSession)!
        if let image = nextThumbnail {
            self.airImageView?.image = image
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                self?.leftView?.top = -(self!.leftView!.height / CGFloat(3.0))*2.0
                return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    func prevSession() {
        self.currentIndexSession!++
        if self.currentIndexSession < 0 {
            self.currentIndexSession = self.sessionViews!.count - 1
        }
        
        // Get thumbnailImage
        let lastIndexInThisSession: NSIndexPath = NSIndexPath(forRow: self.lastIndexInSession![self.currentIndexSession!]!, inSection: self.currentIndexSession!)

        
        let prevThumbnail: UIImage? = self.getThumbnailImageAtIndexPath(lastIndexInThisSession)!
        if let prev = prevThumbnail {
            self.airImageView?.image = prevThumbnail
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
            self?.leftView?.top = 0
            return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    func slideCurrentSession() {
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
            self?.leftView?.top = -self!.leftView!.height/3
            return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
    }
    
    func rotateAirImage() {
        
        if self.lastDeegreesRotateTransform > 0 {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                
                var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                airImageRotate = CATransform3DRotate(airImageRotate, CGFloat(AirDegreesToRadians(self!.lastDeegreesRotateTransform!)),0,1,0)
                self?.airImageView?.layer.transform = airImageRotate
                
                return
                }, completion: {(finished: Bool) -> Void in
                    self.lastDeegreesRotateTransform = 0
            })
        } else {
            
            let rotateDegress: CGFloat = abs(CGFloat(kAirImageViewRotateMax) - CGFloat(kAirImageViewRotate)) as CGFloat
            
            UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                
                    var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                    airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(-rotateDegress), 0, 1, 0)
                    self?.airImageView?.layer.transform = airImageRotate
                
                return
                }, completion: {(finished: Bool) -> Void in
                    UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                        var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                        airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(rotateDegress), 0, 1, 0)
                        self?.airImageView?.layer.transform = airImageRotate
                        return
                        }, completion: {(finished: Bool) -> Void in
                            self.lastDeegreesRotateTransform = 0
                    })
            })
        }
        
    }
    
    // layout menu
    
    func reloadData() {
        
        if self.dataSource == nil {
            return
        }
        
        // Get number session
        self.session = self.dataSource?.numberOfSession()
        
        // Get height
        if self.delegate?.respondsToSelector("heightForAirMenuRow") != nil{
            self.heightAirMenuRow = CGFloat(self.delegate!.heightForAirMenuRow!())
        }
        
        var tempThumbnails: [Dictionary<Int, UIView>] = [Dictionary<Int, UIView>()]
        var tempViewControllers: [Dictionary<Int, UIViewController>] = [Dictionary<Int, UIViewController>()]
        
        for (var i:Int=0; i<self.session; i++) {
            tempThumbnails.append(Dictionary<Int, UIView>())
            tempViewControllers.append(Dictionary<Int, UIViewController>())
        }
        self.thumbnailImages = tempThumbnails
        self.viewControllers = tempViewControllers
        
        // Get number rows of session
        var temp: Array = [Int]()
        for (var i:Int = 0; i < self.session; i++) {
            temp.append(self.dataSource!.numberOfRowsInSession(i))
        }
        self.rowsOfSession = temp
        
        // Init AirbnbSessionView
        let sessionHeight: CGFloat = CGFloat(self.view.frame.size.height - kHeaderTitleHeight)
        for (var i:Int = 0; i < self.session; i++) {
            var sessionView: AirbnbSessionView? = self.sessionViews![i]!
            if sessionView == nil {
                sessionView = AirbnbSessionView(frame:CGRectMake(30, 0, CGFloat(kSessionWidth), sessionHeight))
                sessionView?.button?.setTitleColor(UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0), forState: UIControlState.Normal)
                sessionView?.button?.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                sessionView?.button?.tag = i
                sessionView?.button?.addTarget(self, action: "sessionButtonTouch:", forControlEvents: UIControlEvents.TouchUpInside)
                self.sessionViews![i] = sessionView!
            }
            // Set title for header session
            if self.dataSource?.respondsToSelector("titleForHeaderAtSession:") != nil {
                let sesionTitle: String = self.dataSource!.titleForHeaderAtSession(i)
                sessionView?.button?.setTitle(sesionTitle, forState: UIControlState.Normal)
            }
        }
        
        // Init menu item for session
        for (var i:Int = 0; i < self.session; i++) {
            var sessionView: AirbnbSessionView? = sessionViews![i]!
            // Remove all sub-view for contain of PHSessionView
            for view in sessionView!.containView!.subviews {
                view.removeFromSuperview()
            }
            
            var firstTop: Int = Int(sessionView!.containView!.frame.size.height) - Int(self.rowsOfSession![i])

            if firstTop < 0 {
                firstTop = 0
            }
            
            for (var j: Int = 0; j < self.rowsOfSession![i]; j++) {
                let title: String = self.dataSource!.titleForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i))
                var button: UIButton? = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
                button!.setTitle(title, forState: UIControlState.Normal)
                button!.addTarget(self, action: "rowDidTouch:", forControlEvents: UIControlEvents.TouchUpInside)
                button!.setTitleColor(self.titleNormalColor, forState: UIControlState.Normal)
                button!.setTitleColor(self.titleHighlightColor, forState: UIControlState.Highlighted)
                button!.setTitleColor(self.titleHighlightColor, forState: UIControlState.Selected)
                button?.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
                button?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                let y: CGFloat = CGFloat(firstTop) + CGFloat(self.heightAirMenuRow!) * CGFloat(j)
                button?.frame = CGRectMake(0, y, 200, self.heightAirMenuRow!);
                button?.tag = j;
                sessionView!.containView!.tag = i;
                sessionView?.containView?.addSubview(button!)
            }
        }
        
        self.layoutContaintView()
    }
    
    func layoutContaintView() {
        if (sessionViews!.count == 1) {
            middleSession = sessionViews![0]
            self.topSession = nil
            self.bottomSession = nil
            
            middleSession?.top = middleSession!.height
            self.leftView?.addSubview(middleSession!)
            
            self.leftView?.top = -(self.leftView!.height)/3
            
            self.updateButtonColor()
            return
        }
        
        if let ts = self.topSession?.superview {
            self.topSession?.removeFromSuperview()
            self.topSession = nil
        }
        
        if let ms = self.middleSession?.superview {
            self.middleSession?.removeFromSuperview()
            self.middleSession = nil
        }
        
        if let bs = self.bottomSession?.superview {
            self.bottomSession?.removeFromSuperview()
            self.bottomSession = nil
        }
        
        // Init top/middle/bottom session view
        if sessionViews!.count == 1 {
            self.middleSession = sessionViews![0]
            self.topSession = self.duplicate(self.middleSession!)
            self.bottomSession = self.duplicate(self.middleSession!)
        } else if sessionViews!.count == 2 {
            self.middleSession = sessionViews![self.currentIndexSession!]
            if currentIndexSession! == 0 {
                self.topSession = self.duplicate(self.sessionViews![1]!)
                self.bottomSession = self.sessionViews![1]!
            } else {
                self.topSession = self.duplicate(self.sessionViews![0]!)
                self.bottomSession = self.sessionViews![0]!
            }
        } else {
            self.middleSession = sessionViews![self.currentIndexSession!]
            if self.currentIndexSession! == 0 {
                self.topSession = self.sessionViews![self.sessionViews!.count - 1]
            } else {
                self.topSession = self.sessionViews![self.currentIndexSession! - 1]
            }
            if self.currentIndexSession! + 1 >= self.sessionViews?.count {
                self.bottomSession = sessionViews![0]
            } else {
                self.bottomSession = self.sessionViews![self.currentIndexSession! + 1]
            }
        }
        
        // Pos for top/middle/bottom session
        self.topSession!.top    = 0;
        self.middleSession!.top = self.topSession!.bottom;
        self.bottomSession!.top = self.middleSession!.bottom;
        
        // Add top/middle/bottom to content view
        self.leftView?.addSubview(self.topSession!)
        self.leftView?.addSubview(self.middleSession!)
        self.leftView?.addSubview(self.bottomSession!)
        
        self.leftView!.top = -(self.leftView!.height)/3
        
        self.updateButtonColor()
    }
    
    func updateButtonColor() {
        
    }
    
    // PHAirMenuDelegate
    
    func numberOfSession() -> Int {
        
        return 0
    }
    
    func numberOfRowsInSession(sesion: Int) -> Int {
        
        return 0
    }
    
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        
        return ""
    }
    
    func titleForHeaderAtSession(session: Int) -> String {
        
        return ""
    }
    
    func segueForAtIndexPath(indexPath: NSIndexPath) -> String {
        return ""
    }
    
    // Button action
    
    func sessionButtonTouch(buttton: UIButton) {
        if buttton.tag == self.currentIndexSession! {
            return
        } else {
            self.nextSession()
        }
    }
    
    func rowDidTouch(button: UIButton) {
        // Save row touch in session
        self.lastIndexInSession![self.currentIndexSession!] = button.superview!.tag
        
        self.currentIndexPath = NSIndexPath(forRow: button.tag, inSection: button.superview!.tag)
        // Should select ?
        if self.delegate != nil && self.delegate?.respondsToSelector("didSelectRowAtIndex:") != nil {
            self.delegate?.didSelectRowAtIndex!(self.currentIndexPath!)
        }
        
        // Get thumbnailImage
        if let nextThumbnail = self.getThumbnailImageAtIndexPath(self.currentIndexPath!)? {
            self.airImageView!.image = nextThumbnail
        }
        
        self.hideAirViewOnComplete({() -> Void in
            let controller: UIViewController? = self.getViewControllerAtIndexPath(self.currentIndexPath!)?
            if controller != nil {
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath!)
            } else if self.storyboard != nil {
                
                if self.dataSource != nil && self.dataSource?.respondsToSelector("segueForRowAtIndexPath:") != nil {
                    let segue: NSString? = self.dataSource?.segueForAtIndexPath!(self.currentIndexPath!)
                    if segue?.length != 0 {
                        self.performSegueWithIdentifier(segue, sender: nil)
                    }
                } else {
                    if self.dataSource != nil && self.dataSource?.respondsToSelector("viewControllerForIndexPath:") != nil {
                        let controller: UIViewController? = self.dataSource?.viewControllerForIndexPath!(self.currentIndexPath!)
                        self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath!)
                    }
                }
                
            } else {
                let controller: UIViewController! = self.dataSource?.viewControllerForIndexPath!(self.currentIndexPath!)
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath!)
            }
            
        })
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
    
    func duplicate(view: AirbnbSessionView) -> AirbnbSessionView? {
        return nil
    }
    
    deinit {
        
    }
}

// AirViewControllerSegue Class

class AirViewControllerSegue: UIStoryboardSegue {
    
    var peformHandler = {(segue: AirViewControllerSegue, svc: UIViewController, dvc: UIViewController) -> Void in
        
    }
}

    // EXtension UIViewController

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
    // EXtension UIView

extension UIView {
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height;
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = bottom - frame.size.height
            self.frame = frame
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPointMake(newValue, self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPointMake(self.center.x, newValue)
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame: CGRect = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var ttScreenX: CGFloat {
        get {
            var x: CGFloat = 0
            var view: UIView? = self
            for (view; view? == nil; view?.superview) {
               x += view!.left
            }
            return x
        }
    }
    
    var ttScreenY: CGFloat {
        get {
            var y: CGFloat = 0
            var view: UIView? = self
            for (view; view? == nil; view?.superview) {
                y += view!.top
            }
            return y
        }
    }
    
    var screenViewX: CGFloat {
        get {
            var x: CGFloat = 0
            var view: UIView? = self
            for (view; view? == nil; view?.superview) {
                x += view!.left
                if view!.isKindOfClass(UIScrollView) {
                    var scrollView: UIScrollView = view as UIScrollView
                    x -= scrollView.contentOffset.x
                }
            }
            return x
        }
    }
    
    var screenViewY: CGFloat {
        get {
            var y: CGFloat = 0
            var view: UIView? = self
            for (view; view? == nil; view?.superview) {
                y += view!.top
                if view!.isKindOfClass(UIScrollView) {
                    var scrollView: UIScrollView = view as UIScrollView
                    y -= scrollView.contentOffset.y
                }
            }
            return y
        }
    }
    
    var screenFrame: CGRect {
        get {
            return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var allSubviews: NSArray {
        get {
            var arr: NSMutableArray = []
            arr.addObject(self)
            for subView in self.subviews {
                arr.addObjectsFromArray(subView.allSubviews)
            }
            return arr
        }
    }
}

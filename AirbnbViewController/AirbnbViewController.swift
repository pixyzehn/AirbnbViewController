//
//  AirbnbViewController.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol AirbnbMenuDelegate: NSObjectProtocol {
    optional func shouldSelectRowAtIndex(indexPath: NSIndexPath) -> Bool
    optional func didSelectRowAtIndex(indexPath: NSIndexPath)
    optional func willShowAirViewController()
    optional func willHideAirViewController()
    optional func didHideAirViewController()
    optional func heightForAirMenuRow() -> CGFloat
    optional func indexPathDefaultValue() -> NSIndexPath?
}

@objc public protocol AirbnbMenuDataSource: NSObjectProtocol {
    func numberOfSession() -> Int
    func numberOfRowsInSession(sesion: Int) -> Int
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String
    func titleForHeaderAtSession(session: Int) -> String
    optional func thumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage?
    optional func viewControllerForIndexPath(indexPath: NSIndexPath) -> UIViewController
}

public let kSessionWidth: CGFloat          = 220
public let kLeftViewTransX: CGFloat        = -50
public let kLeftViewRotate: CGFloat        = -5
public let kAirImageViewRotate: CGFloat    = -25
public let kRightViewTransX: CGFloat       = 180
public let kRightViewTransZ: CGFloat       = -150
public let kAirImageViewRotateMax: CGFloat = -42
public let kDuration                       = 0.2
public let kIndexPathOutMenu               = NSIndexPath(forRow: 999, inSection: 0)
public let kHeaderTitleHeight: CGFloat     = 80

//MARK: Convert unit

private var AirDegreesToRadians = {(degrees: CGFloat) -> CGFloat in
    return degrees * CGFloat(M_PI) / 180.0
}

private var AirRadiansToDegrees = {(radians: CGFloat) -> CGFloat in
    return radians * 180 / CGFloat(M_PI)
}

public class AirbnbViewController: UIViewController, AirbnbMenuDelegate, AirbnbMenuDataSource, UIGestureRecognizerDelegate {
 
    public var titleNormalColor: UIColor?
    public var titleHighlightColor: UIColor?
    public var delegate: AirbnbMenuDelegate?
    public var dataSource: AirbnbMenuDataSource?
    public var fontViewController: UIViewController?
    public var currentIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    public let complete = ({ () -> Void in })
   
    private var _wrapperView: UIView?
    public var wrapperView: UIView? {
        get {
            if let wv = _wrapperView {
                return wv
            } else {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                _wrapperView = view
                return view
            }
        }
        set {
            _wrapperView = newValue
        }
    }

    private var _contentView: UIView?
    public var contentView: UIView? {
        get {
            if let cv = _contentView {
                return cv
            } else {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                _contentView = view
                return view
            }
        }
        set {
            _contentView = newValue
        }
    }
    
    private var _leftView: UIView?
    public var leftView: UIView? {
        get {
            if let lv = _leftView {
                return lv
            } else {
                let view: UIView = UIView(frame: CGRectMake(0, -(self.view.height - kHeaderTitleHeight), kSessionWidth, (self.view.height - kHeaderTitleHeight) * 3))
                view.userInteractionEnabled = true
                _leftView = view
                return view
            }
        }
        set {
            _leftView = newValue
        }
    }
    
    private var _rightView: UIView?
    public var rightView: UIView? {
        get {
            if let rv = _rightView {
                return rv
            } else {
                let view: UIView = UIView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                view.userInteractionEnabled = true
                _rightView = view
                return view
            }
        }
        set {
            _rightView = newValue
        }
    }
    
    private var _airImageView: UIImageView?
    public var airImageView: UIImageView? {
        get {
            if let aiv = _airImageView {
                return aiv
            } else {
                let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.width, self.view.height))
                imageView.userInteractionEnabled = true
                _airImageView = imageView
                return imageView
            }
        }
        set {
            _airImageView = newValue
        }
    }

    private var lastDeegreesRotateTransform: CGFloat?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    public var session: Int?
    public var rowsOfSession: [Int]?
    public var sessionViews: Dictionary<Int, AirbnbSessionView>?
    public var currentIndexSession: Int = 0
    public var isAnimation: Bool?
    public var topSession: AirbnbSessionView?
    public var middleSession: AirbnbSessionView?
    public var bottomSession: AirbnbSessionView?
    public var lastIndexInSession: Dictionary<Int, Int> = [0:0]
    public var thumbnailImages: [Dictionary<Int, UIImage>]?
    public var viewControllers: [Dictionary<Int, UIViewController>]?
    public var heightAirMenuRow: CGFloat?
 
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(viewController: UIViewController, atIndexPath:NSIndexPath) {
        self.init()
        let rect = UIScreen.mainScreen().applicationFrame
        self.view.frame = CGRectMake(0, 0, rect.width, rect.height)
        self.bringViewControllerToTop(viewController, indexPath: atIndexPath)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sessionViews = Dictionary<Int, AirbnbSessionView>()
        
        currentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        self.delegate = self
        self.dataSource = self
        
        self.view.addSubview(wrapperView!)
        self.wrapperView?.addSubview(contentView!)
        
        self.contentView?.addSubview(leftView!)
        self.contentView?.addSubview(rightView!)
        
        self.rightView?.addSubview(airImageView!)
        
        self.titleNormalColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
        self.titleHighlightColor = UIColor.blackColor()
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeOnAirImageView:")
        swipe.direction = UISwipeGestureRecognizerDirection.Left
        self.airImageView?.addGestureRecognizer(swipe)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapOnAirImageView:")
        self.airImageView?.addGestureRecognizer(tap)
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleRevealGesture:")
        self.panGestureRecognizer?.delegate = self
        self.leftView?.addGestureRecognizer(panGestureRecognizer!)
        
        self.setupAnimation()
        
        self.leftView?.alpha = 0
        self.rightView?.alpha = 0
        
        self.heightAirMenuRow = 44
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    public func bringViewControllerToTop(controller: UIViewController?, indexPath: NSIndexPath) {
        
        if (controller == nil) {
            return
        }
        
        if let fvController = self.fontViewController {
            fvController.removeFromParentViewController()
            fvController.view.removeFromSuperview()
        }
        
        self.fontViewController = controller
        self.currentIndexPath = indexPath
        
        if indexPath.row != kIndexPathOutMenu.row {
            self.lastIndexInSession[indexPath.section] = indexPath.row
            self.saveViewControler(controller, atIndexPath: indexPath)
        }
        
        self.addChildViewController(self.fontViewController!)
        let controllerView: UIView = self.fontViewController!.view
        controllerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        controllerView.frame = self.view.bounds
        self.view.addSubview(controllerView)
        
        self.fontViewController?.didMoveToParentViewController(self)
    }
    
    //MARK: Gesture delegate

    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isAnimation == true {
            return false
        }
        return true
    }
    
    //MARK: AirImageView gesture
    
    public func handleSwipeOnAirImageView(swipe: UISwipeGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.fontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    public func handleTapOnAirImageView(swipe: UITapGestureRecognizer) {
        self.hideAirViewOnComplete({() -> Void in
            self.bringViewControllerToTop(self.fontViewController, indexPath: self.currentIndexPath)
        })
    }
    
    //MARK: Gesture Based Reveal

    public func handleRevealGesture(recognizer: UIPanGestureRecognizer) {
        
        if self.sessionViews?.count == 0 || self.sessionViews?.count == 1 {
            return
        }
        
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            handleRevealGestureStateBeganWithRecognizer(recognizer)
        case UIGestureRecognizerState.Changed:
            handleRevealGestureStateChangedWithRecognizer(recognizer)
        case UIGestureRecognizerState.Ended:
            handleRevealGestureStateEndedWithRecognizer(recognizer)
        case UIGestureRecognizerState.Cancelled:
            handleRevealGestureStateCancelledWithRecognizer(recognizer)
        default:
            break
        }
    }
    
    public func handleRevealGestureStateBeganWithRecognizer(recognizer: UIPanGestureRecognizer) {
    }
    
    public func handleRevealGestureStateChangedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
        let translation: CGFloat = recognizer.translationInView(self.leftView!).y

        self.leftView!.top = -(self.view.height - kHeaderTitleHeight) + translation
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let sessionViewHeight: Int = Int(self.view.height - kHeaderTitleHeight)
        var distanceScroll: Int = 0
        
        if afterTop - firstTop > 0 {
            let topMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight + 40
            
            if topMiddleSessionView < Int(self.view.height / 2) {
                distanceScroll = Int(self.view.height / 2) - topMiddleSessionView
            } else {
                distanceScroll = topMiddleSessionView - Int(self.view.height / 2) + 40
            }
        } else {
            let bottomMiddleSessionView: Int = Int(self.leftView!.top) + sessionViewHeight * 2
            
            if bottomMiddleSessionView > Int(self.view.height / 2) {
                distanceScroll = bottomMiddleSessionView - Int(self.view.height / 2)
            } else {
                distanceScroll = Int(self.view.height / 2) - bottomMiddleSessionView
            }
        }
        
        distanceScroll = abs(Int(self.view.height / 2) - distanceScroll)
        
        let rotateDegress: CGFloat = CGFloat(distanceScroll * Int(abs(kAirImageViewRotateMax - kAirImageViewRotate))) / (self.view.height / 2)
        self.lastDeegreesRotateTransform = rotateDegress
        
        var airImageRotate: CATransform3D = CATransform3DIdentity
        airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(kAirImageViewRotate - rotateDegress), 0, 1, 0)
        self.airImageView?.layer.transform = airImageRotate
    }
    
    //MARK: Judge whether to transit or not
    
    public func handleRevealGestureStateEndedWithRecognizer(recognizer: UIPanGestureRecognizer) {
        
        if sessionViews?.count == 0 {
            return
        }
        
        let firstTop: Int = -Int(self.view.height - kHeaderTitleHeight)
        let afterTop: Int = Int(self.leftView!.top)
        
        let velocity: CGPoint = recognizer.velocityInView(recognizer.view)
        
        if afterTop - firstTop > 0 {
            if afterTop - firstTop > Int(self.view.height / 2) - 40 || abs(velocity.y) > 100 {
                self.prevSession()
            } else {
                self.slideCurrentSession()
            }
        } else {
            if firstTop - afterTop > Int(self.view.height / 2) - 40 || abs(velocity.y) > 100 {
                self.nextSession()
            } else {
                self.slideCurrentSession()
            }
        }
    }
    
    public func handleRevealGestureStateCancelledWithRecognizer(recognizer: UIPanGestureRecognizer) {
    }
    
    public func nextSession() {
        self.currentIndexSession++
        if self.currentIndexSession >= self.sessionViews?.count {
            self.currentIndexSession = 0
        }
        
        if let index = self.lastIndexInSession[self.currentIndexSession] {
            let lastIndexInThisSession: NSIndexPath = NSIndexPath(forRow:index, inSection: self.currentIndexSession)
            let nextThumbnail: UIImage? = self.getThumbnailImageAtIndexPath(lastIndexInThisSession)
            if let image = nextThumbnail {
                self.airImageView?.image = image
            }
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                self?.leftView?.top = -(self!.leftView!.height / 3.0) * 2.0
                return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    public func prevSession() {
        self.currentIndexSession--
        if self.currentIndexSession < 0 {
            self.currentIndexSession = self.sessionViews!.count - 1
        }
        
        if let index = self.lastIndexInSession[self.currentIndexSession] {
            let lastIndexInThisSession: NSIndexPath = NSIndexPath(forRow: index, inSection: self.currentIndexSession)
            let prevThumbnail: UIImage? = self.getThumbnailImageAtIndexPath(lastIndexInThisSession)
            if let prev = prevThumbnail {
                self.airImageView?.image = prev
            }
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
            self?.leftView?.top = 0
            return
            }, completion: {(finished: Bool) -> Void in
                self.layoutContaintView()
        })
        
        self.rotateAirImage()
    }
    
    public func slideCurrentSession() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
            self!.leftView!.top = -self!.leftView!.height / 3.0
            return
            }, completion: {(finished: Bool) -> Void in
        })
        
        self.rotateAirImage()
    }
    
    public func rotateAirImage() {
        if self.lastDeegreesRotateTransform > 0 {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                    var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                    airImageRotate = CATransform3DRotate(airImageRotate, CGFloat(AirDegreesToRadians(self!.lastDeegreesRotateTransform!)),0,1,0)
                    self?.airImageView?.layer.transform = airImageRotate
                }, completion: {(finished: Bool) -> Void in
                    self.lastDeegreesRotateTransform = 0
            })
        } else {
            let rotateDegress: CGFloat = abs(kAirImageViewRotateMax - kAirImageViewRotate) as CGFloat
            
            UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                    var airImageRotate: CATransform3D = self!.airImageView!.layer.transform
                    airImageRotate = CATransform3DRotate(airImageRotate, AirDegreesToRadians(-rotateDegress), 0, 1, 0)
                    self?.airImageView?.layer.transform = airImageRotate
                
                return
                }, completion: {(finished: Bool) -> Void in
                    UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,  animations: {[weak self]() -> Void in
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
    
    public func reloadData() {
        if self.dataSource == nil {
            return
        }
        
        self.session = self.dataSource?.numberOfSession()
        
        if let heightForAirMenuRow = self.delegate?.heightForAirMenuRow?() {
            self.heightAirMenuRow = heightForAirMenuRow
        }
        
        var tempThumbnails: [Dictionary<Int, UIImage>] = [Dictionary<Int, UIImage>()]
        var tempViewControllers: [Dictionary<Int, UIViewController>] = [Dictionary<Int, UIViewController>()]
        
        for var i:Int = 0; i < self.session; i++ {
            tempThumbnails.append(Dictionary<Int, UIImage>())
            tempViewControllers.append(Dictionary<Int, UIViewController>())
        }
        self.thumbnailImages = tempThumbnails
        self.viewControllers = tempViewControllers
        
        var temp: Array = [Int]()
        for var i:Int = 0; i < self.session; i++ {
            temp.append(self.dataSource!.numberOfRowsInSession(i))
            
        }
        self.rowsOfSession = temp
        
        let sessionHeight: CGFloat = CGFloat(self.view.frame.size.height - kHeaderTitleHeight)
        
        for var i:Int = 0; i < self.session; i++ {
            var sessionView: AirbnbSessionView? = self.sessionViews![i]
            if sessionView == nil {
                sessionView = AirbnbSessionView(frame:CGRectMake(30, 0, kSessionWidth, sessionHeight))
                sessionView?.button?.setTitleColor(UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0), forState: UIControlState.Normal)
                sessionView?.button?.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                sessionView?.button?.tag = i
                sessionView?.button?.addTarget(self, action: "sessionButtonTouch:", forControlEvents: UIControlEvents.TouchUpInside)
                self.sessionViews![i] = sessionView!
            }
            let sesionTitle: String? = self.dataSource?.titleForHeaderAtSession(i)
            sessionView?.button?.setTitle(sesionTitle, forState: UIControlState.Normal)
        }
        
        for var i:Int = 0; i < self.session; i++ {
            var sessionView: AirbnbSessionView? = sessionViews![i]!

            for view in sessionView!.containView!.subviews {
                view.removeFromSuperview()
            }
            
            var firstTop: Int = (Int(sessionView!.containView!.frame.size.height) - (self.rowsOfSession![i] * Int(self.heightAirMenuRow!))) / 2

            if firstTop < 0 {
                firstTop = 0
            }
            
            for var j: Int = 0; j < self.rowsOfSession![i]; j++ {
                let title: String = self.dataSource!.titleForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i))
                var button: UIButton? = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
                button!.setTitle(title, forState: UIControlState.Normal)
                button!.addTarget(self, action: "rowDidTouch:", forControlEvents: UIControlEvents.TouchUpInside)
                button!.setTitleColor(self.titleNormalColor, forState: UIControlState.Normal)
                button!.setTitleColor(self.titleHighlightColor!, forState: UIControlState.Highlighted)
                button!.setTitleColor(self.titleHighlightColor!, forState: UIControlState.Selected)
                button!.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 16)
                button!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                let y: CGFloat = CGFloat(firstTop) + CGFloat(self.heightAirMenuRow!) * CGFloat(j)
                button!.frame = CGRectMake(0, y, 200, CGFloat(self.heightAirMenuRow!))
                button!.tag = j
                sessionView!.containView!.tag = i
                sessionView?.containView?.addSubview(button!)
            }
        }
        self.layoutContaintView()
    }
    
    public func layoutContaintView() {
        if sessionViews!.count == 1 {
            middleSession = sessionViews![0]
            self.topSession = nil
            self.bottomSession = nil
            
            middleSession?.top = middleSession!.height
            self.leftView?.addSubview(middleSession!)
            
            self.leftView?.top = -(self.leftView!.height) / 3
            
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
        
        if sessionViews!.count == 1 {
            // count 1
            self.middleSession = self.sessionViews![0]
            self.topSession = self.duplicate(self.middleSession!) as? AirbnbSessionView
            self.bottomSession = self.duplicate(self.middleSession!) as? AirbnbSessionView
        } else if sessionViews!.count == 2 {
            // count 2
            self.middleSession = self.sessionViews![self.currentIndexSession]
            if currentIndexSession == 0 {
                var hoge = self.sessionViews
                self.topSession = self.sessionViews![1]!
                self.bottomSession = self.duplicate(self.sessionViews![1]!) as? AirbnbSessionView
            } else {
                self.topSession = self.sessionViews![0]!
                self.bottomSession = self.duplicate(self.sessionViews![0]!) as? AirbnbSessionView
            }
        } else {
            //count more than 3
            self.middleSession = sessionViews![self.currentIndexSession]
            if self.currentIndexSession == 0 {
                self.topSession = self.sessionViews![self.sessionViews!.count - 1]
            } else {
                self.topSession = self.sessionViews![self.currentIndexSession - 1]
            }
            if self.currentIndexSession + 1 >= self.sessionViews?.count {
                self.bottomSession = sessionViews![0]
            } else {
                self.bottomSession = self.sessionViews![self.currentIndexSession + 1]
            }
        }
        
        self.topSession!.top    = 0
        self.middleSession!.top = self.topSession!.bottom
        self.bottomSession!.top = self.middleSession!.bottom
        
        self.leftView?.addSubview(self.topSession!)
        self.leftView?.addSubview(self.middleSession!)
        self.leftView?.addSubview(self.bottomSession!)
        
        self.leftView!.top = -(self.leftView!.height)/3
        
        self.updateButtonColor()
    }
    
    public func updateButtonColor() {
        for var i: Int = 0; i < self.sessionViews?.count; i++ {
            var sessionView: AirbnbSessionView? = self.sessionViews?[i]
            var indexHighlight: Int? = self.lastIndexInSession[i]
            
            for object in sessionView!.containView!.allSubviews {
                if object is UIButton {
                    var button: UIButton = object as! UIButton
                    button.highlighted = button.tag == indexHighlight ? true : false
                }
            }
        }
    }
    
    //MARK: PHAirMenuDelegate
    
    public func numberOfSession() -> Int {
        return 0
    }
    
    public func numberOfRowsInSession(sesion: Int) -> Int {
        return 0
    }
    
    public func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        return ""
    }
    
    public func titleForHeaderAtSession(session: Int) -> String {
        return ""
    }
    
    //MARK: Button action
    
    public func sessionButtonTouch(buttton: UIButton) {
        if buttton.tag == self.currentIndexSession {
            return
        } else {
            self.nextSession()
        }
    }
    
    public func rowDidTouch(button: UIButton) {

        self.lastIndexInSession[self.currentIndexSession] = button.superview!.tag
        
        self.currentIndexPath = NSIndexPath(forRow: button.tag, inSection: button.superview!.tag)
        
        if self.delegate != nil && self.delegate?.respondsToSelector("didSelectRowAtIndex:") != nil {
            self.delegate?.didSelectRowAtIndex!(self.currentIndexPath)
        }
        
        if let nextThumbnail = self.getThumbnailImageAtIndexPath(self.currentIndexPath) {
            self.airImageView!.image = nextThumbnail
        }
        
        self.hideAirViewOnComplete({() -> Void in
            let controller: UIViewController? = self.getViewControllerAtIndexPath(self.currentIndexPath)
            if controller != nil {
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath)
            } else {
                let controller: UIViewController! = self.dataSource?.viewControllerForIndexPath!(self.currentIndexPath)
                self.bringViewControllerToTop(controller, indexPath: self.currentIndexPath)
            }
            
        })
    }
    
    //MARK: Show/Hide air view controller
    
    public func showAirViewFromViewController(controller: UIViewController?, complete: (() -> Void)? ) {
        self.updateButtonColor()
        
        if let willShow: () = self.delegate?.willShowAirViewController?() {
            willShow
        }
        
        self.airImageView?.image = self.imageWithView(controller!.view)
        self.saveThumbnailImage(self.airImageView?.image, atIndexPath: self.currentIndexPath)
        self.saveViewControler(controller, atIndexPath: self.currentIndexPath)
        
        self.view.bringSubviewToFront(self.wrapperView!)
        self.contentView?.bringSubviewToFront(self.leftView!)
        self.contentView?.bringSubviewToFront(self.rightView!)
        
        if controller != nil {
            controller?.removeFromParentViewController()
            controller?.view.removeFromSuperview()
        }
        
        self.airImageView?.layer.transform = CATransform3DIdentity
        self.contentView?.layer.transform = CATransform3DIdentity
        
        var leftTransform: CATransform3D = CATransform3DIdentity
        leftTransform = CATransform3DTranslate(leftTransform, kLeftViewTransX, 0, 0)
        leftTransform = CATransform3DRotate(leftTransform, AirDegreesToRadians(kLeftViewRotate), 0, 1, 0)
        self.leftView?.layer.transform = leftTransform
        
        self.rightView?.alpha = 1
        self.leftView?.alpha = 0
        
        UIView.animateWithDuration(kDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
            self?.leftView?.alpha = 1
            
            var airImageRotate: CATransform3D? = self?.airImageView?.layer.transform
            airImageRotate = CATransform3DRotate(airImageRotate!, AirDegreesToRadians(kAirImageViewRotate), 0, 1, 0)
            self?.airImageView?.layer.transform = airImageRotate!
            
            var rightTransform: CATransform3D? = self?.rightView?.layer.transform
            rightTransform = CATransform3DTranslate(rightTransform!, kRightViewTransX, 0, kRightViewTransZ)
            self?.rightView?.layer.transform = rightTransform!
            
            var leftTransform: CATransform3D? = self?.leftView?.layer.transform
            leftTransform = CATransform3DRotate(leftTransform!, AirDegreesToRadians(-kLeftViewRotate), 0, 1, 0)
            leftTransform = CATransform3DTranslate(leftTransform!, -kLeftViewTransX , 0, 0)
            self?.leftView?.layer.transform = leftTransform!
            
            return
            }, completion: {(finished: Bool) -> Void in
                if let com = complete {
                    com()
                }
        })
        
        self.airImageView?.tag = 1
    }
    
    public func switchToViewController(controller: UIViewController, atIndexPath: NSIndexPath) {
        self.bringViewControllerToTop(controller, indexPath: atIndexPath)
    }
    
    public func switchToViewController(controller: UIViewController) {
        self.bringViewControllerToTop(controller, indexPath: kIndexPathOutMenu)
    }
    
    public func hideAirViewOnComplete(complete: (() -> Void)?) {
        if let willHide: () = self.delegate?.willHideAirViewController?() {
            willHide
        }
        
        UIView.animateWithDuration(kDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self]() -> Void in
                self?.leftView?.alpha = 0
            
                var airImageRotate: CATransform3D? = self?.airImageView?.layer.transform
                airImageRotate = CATransform3DRotate(airImageRotate!, AirDegreesToRadians(-kAirImageViewRotate), 0, 1, 0)
                self?.airImageView?.layer.transform = airImageRotate!
            
                var rightTransform: CATransform3D? = self?.rightView?.layer.transform
                rightTransform = CATransform3DTranslate(rightTransform!, -kRightViewTransX, 0, -kRightViewTransZ)
                self?.rightView?.layer.transform = rightTransform!
 
                var leftTransform: CATransform3D? = self?.leftView?.layer.transform
                leftTransform = CATransform3DRotate(leftTransform!, AirDegreesToRadians(kLeftViewRotate), 0, 1, 0)
                leftTransform = CATransform3DTranslate(leftTransform!, kLeftViewTransX, 0, 0)
                self?.leftView?.layer.transform = leftTransform!
            
            }, completion: {(finished: Bool) -> Void in
                self.leftView?.alpha = 0
                self.rightView?.alpha = 0
                
                self.leftView?.layer.transform = CATransform3DIdentity
                
                if let didHide: () = self.delegate?.didHideAirViewController?() {
                    didHide
                }
                if let com = complete {
                    com()
                }
        })

        self.airImageView?.tag = 0
    }

    //MARK: Animation
    
    public func setupAnimation() {
        var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -600
        
        self.rightView?.layer.sublayerTransform = rotationAndPerspectiveTransform

        let anchorPoint: CGPoint = CGPointMake(1, 0.5)
        let newX: CGFloat = self.airImageView!.width * anchorPoint.x
        let newY: CGFloat = self.airImageView!.height * anchorPoint.y
        self.airImageView!.layer.position = CGPointMake(newX, newY)
        self.airImageView!.layer.anchorPoint = anchorPoint
        
        self.contentView?.layer.sublayerTransform = rotationAndPerspectiveTransform
        let anchorPoint2: CGPoint = CGPointMake(1, 0.5)
        let newX2: CGFloat = self.rightView!.width * anchorPoint2.x
        let newY2: CGFloat = self.rightView!.height * anchorPoint2.y
        self.rightView!.layer.position = CGPointMake(newX2, newY2)
        self.rightView!.layer.anchorPoint = anchorPoint2
        
        let leftAnchorPoint: CGPoint = CGPointMake(-3, 0.5)
        let newLeftX: CGFloat = self.leftView!.width * leftAnchorPoint.x
        let newLeftY: CGFloat = self.leftView!.height * leftAnchorPoint.y
        self.leftView!.layer.position = CGPointMake(newLeftX, newLeftY)
        self.leftView!.layer.anchorPoint = leftAnchorPoint
        
        let anchorPoint3: CGPoint = CGPointMake(1, 0.5)
        let newX3: CGFloat = self.contentView!.width * anchorPoint3.x
        let newY3: CGFloat = self.contentView!.height * anchorPoint3.y
        self.contentView!.layer.position = CGPointMake(newX3, newY3)
        self.contentView!.layer.anchorPoint = anchorPoint3
    }
    
    //MARK: Helper
    
    public func getThumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        let thumbnailDic: Dictionary = self.thumbnailImages![indexPath.section]
        if let tDic = thumbnailDic[indexPath.row] {
            return tDic
        } else {
            if let th = self.dataSource?.thumbnailImageAtIndexPath?(indexPath) {
                return th
            } else {
                return nil
            }
        }
    }
    
    public func saveThumbnailImage(image: UIImage?, atIndexPath indexPath: NSIndexPath) {
        if image == nil {
            return
        }
        
        var thumbnailDic: Dictionary = self.thumbnailImages![indexPath.section]
        thumbnailDic[indexPath.row] = image!
    }
    
    public func getViewControllerAtIndexPath(indexPath: NSIndexPath) -> UIViewController? {
        let viewControllerDic: Dictionary = self.viewControllers![indexPath.section]
        if let vDic = viewControllerDic[indexPath.row] {
            return vDic
        } else {
            return self.dataSource?.viewControllerForIndexPath!(indexPath)
        }
    }
    
    public func saveViewControler(controller: UIViewController?, atIndexPath indexPath: NSIndexPath) {
        if controller == nil {
            return
        }
        
        var viewControllerDic: Dictionary? = self.viewControllers?[indexPath.section]
        if viewControllerDic != nil {
            viewControllerDic![indexPath.row] = controller
        }
    }
    
    public func imageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    public func duplicate(view: UIView) -> UIView? {
        let tempArchive: NSData = NSKeyedArchiver.archivedDataWithRootObject(view)
        return NSKeyedUnarchiver.unarchiveObjectWithData(tempArchive) as? AirbnbSessionView
    }
    
    deinit {
        self.airImageView?.removeFromSuperview()
        self.airImageView = nil
        self.rightView?.removeFromSuperview()
        self.rightView = nil
        self.leftView?.removeFromSuperview()
        self.leftView = nil
        self.wrapperView?.removeFromSuperview()
        self.wrapperView = nil
        self.rowsOfSession = nil
    }
}

public var SwipeTagHandle = "SWIPE_HANDER"
public var SwipeObject = "SWIPE_OBJECT"

public extension UIViewController {
    
    public var airSwipeGestureRecognizer: UISwipeGestureRecognizer? {
        get {
            var swipe: UISwipeGestureRecognizer? = objc_getAssociatedObject(self, &SwipeObject) as? UISwipeGestureRecognizer
            if let sw = swipe {
                return sw
            } else {
                swipe = UISwipeGestureRecognizer(target: self, action: "swipeHandler")
                swipe?.direction = UISwipeGestureRecognizerDirection.Right
                objc_setAssociatedObject(self, &SwipeObject, swipe, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                return swipe
            }
            
        }
    }
    
    public var airSwipeHandler: airHandler? {
        get {
            // AnyObject -> id -> airHandler
            return AirbnbHelper.usingAnyObjectWrapper(objc_getAssociatedObject(self, &SwipeTagHandle))
        }
        set {
            if var obj: airHandler = newValue {
                if let view = self.airSwipeGestureRecognizer?.view {
                    view.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                
                if let nv = self.navigationController {
                    nv.view.addGestureRecognizer(self.airSwipeGestureRecognizer!)
                } else {
                    self.view.addGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                // airHandler -> id -> AnyObject
                objc_setAssociatedObject(self, &SwipeTagHandle, AirbnbHelper.usingClosureWrapper(obj), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            } else {
                if self.airSwipeGestureRecognizer?.view != nil {
                    self.airSwipeGestureRecognizer?.view?.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
                if let ph = self.airSwipeGestureRecognizer?.view {
                    ph.removeGestureRecognizer(self.airSwipeGestureRecognizer!)
                }
            }
        }
    }
    
    public var airViewController: AirbnbViewController {
        get {
            var parent: UIViewController = self
            var parent2 = parent.parentViewController!
            var parent3 = parent2.parentViewController!
            print(parent)
            return parent3 as! AirbnbViewController
        }
    }
    
    public func swipeHandler() {
        if let handler: airHandler = self.airSwipeHandler {
            handler()
        }
    }
}

//MARK: EXtension UIView

public extension UIView {
    
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame: CGRect = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPointMake(newValue, self.center.y)
        }
    }
    
    public var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPointMake(self.center.x, newValue)
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame: CGRect = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame: CGRect = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    public var ttScreenX: CGFloat {
        get {
            var x: CGFloat = 0
            var view: UIView? = self
            for view; view == nil; view?.superview {
                x += view!.left
            }
            return x
        }
    }
    
    public var ttScreenY: CGFloat {
        get {
            var y: CGFloat = 0
            var view: UIView? = self
            for (view; view == nil; view?.superview) {
                y += view!.top
            }
            return y
        }
    }
    
    public var screenViewX: CGFloat {
        get {
            var x: CGFloat = 0
            var view: UIView? = self
            for (view; view == nil; view?.superview) {
                x += view!.left
                if view!.isKindOfClass(UIScrollView) {
                    var scrollView: UIScrollView = view as! UIScrollView
                    x -= scrollView.contentOffset.x
                }
            }
            return x
        }
    }
    
    public var screenViewY: CGFloat {
        get {
            var y: CGFloat = 0
            var view: UIView? = self
            for (view; view == nil; view?.superview) {
                y += view!.top
                if view!.isKindOfClass(UIScrollView) {
                    var scrollView: UIScrollView = view as! UIScrollView
                    y -= scrollView.contentOffset.y
                }
            }
            return y
        }
    }
    
    public var screenFrame: CGRect {
        get {
            return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height)
        }
    }
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame: CGRect = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame: CGRect = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    public var allSubviews: NSArray {
        get {
            var arr: NSMutableArray = []
            arr.addObject(self)
            for subView in self.subviews {
                arr.addObjectsFromArray(subView.allSubviews! as [AnyObject])
            }
            return arr
        }
    }
}

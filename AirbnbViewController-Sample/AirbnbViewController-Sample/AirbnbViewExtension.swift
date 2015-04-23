//
//  UIView+Extension.swift
//  AirbnbViewController-Sample
//
//  Created by Hiroki Nagasawa on 4/23/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

//MARK: EXtension UIViewController

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

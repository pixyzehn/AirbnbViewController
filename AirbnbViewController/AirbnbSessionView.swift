//
//  AirbnbSessionView.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import Foundation
import UIKit

public class AirbnbSessionView: UIView {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var _button: UIButton?
    public var button: UIButton? {
        get {
            if let btn = _button {
                return btn
            } else {
                _button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
                _button?.frame = CGRectMake(0, 40, frame.size.width, kHeaderTitleHeight - 40.0)
                _button?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                addSubview(_button!)
                return _button
            }
        }
        set {
            _button = newValue
        }
    }

    private var _containView: UIView?
    public var containView: UIView? {
        get {
            if let cv = _containView {
                return cv
            } else {
                _containView = UIView(frame: CGRectMake(0, kHeaderTitleHeight + 20, frame.size.width, frame.size.height - kHeaderTitleHeight))
                addSubview(_containView!)
                return _containView
            }
        }
        set {
            _containView = newValue
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    deinit {
        self.button?.removeFromSuperview()
        self.button = nil
        self.containView?.removeFromSuperview()
        self.containView = nil
    }
}

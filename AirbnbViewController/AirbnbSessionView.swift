//
//  AirbnbSessionView.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import Foundation
import UIKit

class AirbnbSessionView: UIView {
    
    var button: UIButton?
    var containView: UIView?
    
    let kHeaderTitleHeight: CGFloat = 80.0
    
    override init() {
        super.init()
        self.button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        self.button?.frame = CGRectMake(0, 40, self.frame.size.width, kHeaderTitleHeight - 40.0)
        self.button?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.addSubview(self.button!)
        
        self.containView = UIView(frame: CGRectMake(0, kHeaderTitleHeight + 20, self.frame.size.width, self.frame.size.height - kHeaderTitleHeight))
        self.addSubview(self.containView!)
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    deinit {
        self.button?.removeFromSuperview()
        self.containView?.removeFromSuperview()
    }
}

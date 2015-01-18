//
//  ViewController.swift
//  AirbnbViewController
//
//  Created by pixyzehn on 1/1/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, AirbnbMenuDelegate, AirbnbMenuDataSource {

    var data: [[String]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.yellowColor()
        
        let session1: [String] = ["hoge", "fuga"]
        let session2: [String] = ["fufu", "kiki"]
        
        self.data?.append(session1)
        self.data?.append(session2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // AirbnbMenuDelegate

    func numberOfSession() -> Int {
        return data!.count
    }
    
    func numberOfRowsInSession(session: Int) -> Int {
        return data![session].count
    }
    
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        return "Row \(indexPath.row) in \(indexPath.section)"
    }
    
    func titleForHeaderAtSession(session: Int) -> String {
        return "Session \(session)"
    }
    
    func segueForAtIndexPath(indexPath: NSIndexPath) -> String {
        return data![indexPath.section][indexPath.row]
    }
    
    func thumbnailImageAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        return nil
    }
}


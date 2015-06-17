//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

class SidePanelViewController: UITableViewController {
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    @IBAction func wifiSwitchToggle(sender: AnyObject) {
        wifi = wifiSwitch.on
        
        if wifi {
            sim = false
            viewDidAppear(false)
        }
    }
    @IBOutlet weak var btSwitch: UISwitch!
    @IBAction func btSwitchToggle(sender: AnyObject) {
        bt = btSwitch.on
        
        if bt {
            sim = false
            viewDidAppear(false)
        }
    }
    @IBOutlet weak var simSwitch: UISwitch!
    @IBAction func simSwitchToggle(sender: AnyObject) {
        sim = simSwitch.on
        
        if sim {
            wifi = false
            bt = false
            viewDidAppear(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        wifiSwitch.setOn(wifi, animated: false)
        btSwitch.setOn(bt, animated: false)
        simSwitch.setOn(sim, animated: false)
    }
}
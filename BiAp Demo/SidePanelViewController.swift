//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

class SidePanelViewController: UITableViewController {
    
    var btTimer = NSTimer()
    
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
    
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    func refreshRSSILabel() {
        if currentPeripheral != nil {
            currentPeripheral.peripheral.readRSSI()
            let rssi = currentPeripheral.peripheral.RSSI as? Int
            
            if rssi != nil {
                rssiLabel.text = "\(rssi!) dB"
                
                let base = -40
                let distance = (base - rssi!)/6 + 1
                
                distanceLabel.text = "~\(distance)m"
            }
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        wifiSwitch.setOn(wifi, animated: false)
        btSwitch.setOn(bt, animated: false)
        simSwitch.setOn(sim, animated: false)
        
        if !btTimer.valid {
            btTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refreshRSSILabel"), userInfo: nil, repeats: true)

        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        btTimer.invalidate()
    }
    
    @IBAction func resetGraph(sender: AnyObject) {
        
        // Amount of 5 minute intervals in a day
        let capacity = 24 * 60 / 5

        time.removeAllObjects()
        glucoseLevels.removeAllObjects()
        insulinLevels.removeAllObjects()
        
        // Initialise arrays
        if time.count == 0 {
            for x in 0...capacity-1 {
                time.addObject(capacity-x as Int)
            }
        }
        
        if glucoseLevels.count == 0 {
            for x in 0...capacity-1 {
                glucoseLevels.addObject(0 as Float)
            }
        }
        
        if insulinLevels.count == 0 {
            for x in 0...capacity-1 {
                insulinLevels.addObject(0 as Float)
            }
        }
        
        // Get the start of Simulation time
        if(startDateTime == "") {
            var components = NSString(string: "\(NSDate())").componentsSeparatedByString(" ")
            startDateTime = "\(components[0])&\(components[1])"
            lastValueDate = startDateTime
        }
    }
}
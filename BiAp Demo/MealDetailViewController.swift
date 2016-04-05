//
//  MealDetailViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 14/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit

class MealDetailViewController: UIViewController, BEMSimpleLineGraphDelegate {

    var meal = bacon_and_eggs
    var chosenIndex = 0
    var mealSize = 75
    
    // Meal Details
    @IBOutlet weak var mealThumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var glucProfileGraph: BEMSimpleLineGraphView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var choLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    // Meal Size
    @IBOutlet weak var mealSizeSlider: UISlider!
    @IBOutlet weak var mealSizeLabel: UILabel!
    @IBAction func mealSizeChanged(sender: UISlider) {
        var sizeEnglish = "Low"
        let size = Int(sender.value)
        mealSize = size
        
        if size <= 60 {
            sizeEnglish = "Small"
        }
        else if size <= 90 {
            sizeEnglish = "Medium"
        }
        else if size <= 120 {
            sizeEnglish = "Large"
        }
        mealSizeLabel.text = "\(sizeEnglish) - \(size)g"
    }
    
    // Feeding Yoda
    @IBOutlet weak var feedYodaButton: UIButton!
    @IBAction func feedYodaAction(sender: AnyObject) {
        sendData("\((meal.foods[chosenIndex] as! Food).id)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let food = meal.foods[chosenIndex] as! Food
        
        mealThumbnail.image = meal.thumbnail
        mealThumbnail.contentMode = UIViewContentMode.ScaleAspectFill
        mealThumbnail.clipsToBounds = true
        
        nameLabel.text = meal.name
        descLabel.text = food.description
        choLabel.text = "\(food.cho)%"
        proteinLabel.text = "\(food.protein)%"
        fatLabel.text = "\(food.fat)%"
        
        setupGraph()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*********************
    *** Graph
    *********************/

    func setupGraph() {
        glucProfileGraph.enableYAxisLabel = false
        glucProfileGraph.autoScaleYAxis = true
        
        glucProfileGraph.enableReferenceAxisFrame = false
        
        glucProfileGraph.enableXAxisLabel = true
        glucProfileGraph.animationGraphEntranceTime = 1
    }

    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        let food:Food = meal.foods[chosenIndex] as! Food
        return food.glucoseProfile.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let food:Food = meal.foods[chosenIndex] as! Food
        return CGFloat(food.glucoseProfile.objectAtIndex(index) as! NSNumber)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        let food:Food = meal.foods[chosenIndex] as! Food
        return "\(food.glucoseTime.objectAtIndex(index) as! NSNumber)"
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 11
    }
    
    /*********************
    *** Sending Meal
    *********************/
    
    func sendData(data:String) {
        // Send via WiFi
        if wifi {
            let url = NSURL(string: "http://ic-yoda.appspot.com/id?id=\(data)&size=\(mealSize)")
            let request = NSURLRequest(URL: url!)
            _ = NSURLConnection(request: request, delegate:nil, startImmediately: true)
        }
        // Send via Bluetooth
        var sentBT = false
        if bt {
            if state == .CONNECTED {
                currentPeripheral.writeString("D,\(data),0,\(mealSize),0\n")
                addTextToConsole("D,\(data),0,\(mealSize),0\n", dataType: .TX)
                sentBT = true
            }
        }
        
        var title = ""
        var message = ""
        
        if !wifi && !sentBT {
            title = "Yoda NOT Fed!"
            message = ":("
        }
        else {
            title = "Yoda Fed!"
            message = "Yoda just ate \(meal.name) via "
            if wifi && !sentBT {
                message += "WiFi"
            }
            else if !wifi && sentBT {
                message += "Bluetooth"
            }
            else {
                message += "WiFi and Bluetooth"
            }
        }
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func addTextToConsole(string:NSString, dataType:ConsoleDataType) {
        var direction:NSString
        
        switch dataType {
        case .RX:
            direction = "RX"
            break
        case .TX:
            direction = "TX"
            break
        case .LOGGING:
            direction = "LOGGING"
        }
        
        var formatter:NSDateFormatter
        formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        let output:NSString = "[\(formatter.stringFromDate(NSDate()))] \(direction) \(string)"
        
        print(output)
    }
}

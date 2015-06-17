//
//  ViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 11/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit
import CoreBluetooth

/*********************
*** Global Variables
*********************/

// Glucose and Insulin Levels (Drawn on Graph)
var glucoseLevels:NSMutableArray = []
var insulinLevels:NSMutableArray = []
var time:NSMutableArray = []

// For reference when checking for new data
var startDateTime:String = ""
var lastValueDate = ""

// Simulate Values
var sim = true

// Connections
var wifi = false
var bt = false
var state:ConnectionState = .IDLE
var currentPeripheral:UARTPeripheral!

// For BT
var inboxGI:NSMutableArray = []
enum ConnectionState{
    case IDLE
    case SCANNING
    case CONNECTED
}
enum ConsoleDataType{
    case LOGGING
    case RX
    case TX
}

// slide out
@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

/*********************
*** ViewController
*********************/

class CenterViewController: UIViewController, BEMSimpleLineGraphDelegate, CBCentralManagerDelegate, UARTPeripheralDelegate {
    // slide out
    var delegate: CenterViewControllerDelegate?
    @IBAction func puppiesTapped(sender: AnyObject) {
        println("toggleRightPanel")
        delegate?.toggleRightPanel?()
    }
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var yodaPicture: UIImageView!
    @IBOutlet weak var yodaHealth: UILabel!
    
    @IBOutlet weak var glucGraph: BEMSimpleLineGraphView!
    @IBOutlet weak var mealLibraryContainer: UIView!
    @IBOutlet weak var glucLabel: UILabel!
    @IBOutlet weak var insuLabel: UILabel!
    
    
    // Timers
    var timer = NSTimer()
    var graphRefreshTimer = NSTimer()
    var connectBTTimer = NSTimer()
    
    // Last N Values
    var n_values = 0
    
    // Pan Gesture to change N Values/Time Range
    var start_x:CGFloat = 0
    var message:UILabel = UILabel()
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBAction func panAction(sender: AnyObject) {
        let pg = sender as! UIPanGestureRecognizer
        let coordinates = sender.translationInView(glucGraph)
        
        let x:CGFloat = coordinates.x
        
        if pg.state == UIGestureRecognizerState.Began {
            start_x = x
            
            let testFrame : CGRect = CGRectMake(500,350,320,62)
            var testView : UIView = UIView(frame: testFrame)
            testView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            testView.tag = 1
            testView.alpha = 1
            
            message = UILabel(frame: CGRectMake(0, 0, 320, 62))
            message.center = CGPointMake(160,31)
            message.textAlignment = NSTextAlignment.Center
            message.text = ""
            message.textColor = UIColor.whiteColor()
            testView.addSubview(message)
            
            self.view.addSubview(testView)
        }
        
        let diff = (x - start_x)/320.00
        
        // 0 to 320
        if diff < 0.25 {
            n_values = 0
            message.text = "3 Hours"
        }
        else if diff < 0.5 {
            n_values = 1
            message.text = "6 Hours"
        }
        else if diff < 0.75 {
            n_values = 2
            message.text = "12 Hours"
        }
        else if diff < 1 {
            n_values = 3
            message.text = "24 Hours"
        }
        
        if pg.state == UIGestureRecognizerState.Ended {
            var viewToRemove = self.view.viewWithTag(1)
            viewToRemove?.removeFromSuperview()
        }
        
        refreshGraph()
        
    }
    
    // Double Tap Gesture to Play/Pause Graph
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
    @IBAction func doubleTapGesture(sender: UITapGestureRecognizer) {
        println("DoubleTap")
        
        // Play
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refreshValues"), userInfo: nil, repeats: true)
            
            graphRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refreshGraph"), userInfo: nil, repeats: true)
        }
            
        // Pause
        else {
            timer.invalidate()
            graphRefreshTimer.invalidate()
        }
    }
    
    // Bluetooth
    var centralManager:CBCentralManager!
    

    /******************************
    *** View Controller Functions
    ******************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        setupGI()
        
        setupView()
        setupGraph()
        
        setupTimers()
        
        // double tap gesture
        doubleTapGesture.numberOfTapsRequired = 2
        
        // pan gesture
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        
        // settings 4 finger swipe
        backButton.alpha = 0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        // Drop Shadow for Meal Library Container
        mealLibraryContainer.layer.shadowColor = UIColor.blackColor().CGColor
        mealLibraryContainer.layer.shadowOpacity = 0.2
        mealLibraryContainer.layer.shadowRadius = 3.0
        mealLibraryContainer.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }
    
    /*********************
    *** Graph
    *********************/
    
    func setupGraph() {

        glucGraph.enableBezierCurve = true
        
        // Reference Frame (Axis lines)
        glucGraph.enableReferenceAxisFrame = true
        
        // Y Axis
        glucGraph.enableYAxisLabel = true
        glucGraph.autoScaleYAxis = true
        
        // X Axis
        glucGraph.enableXAxisLabel = true
        
        // Animation Time
        glucGraph.animationGraphEntranceTime = 0
        
        // Pop-up
        glucGraph.enablePopUpReport = true
        glucGraph.enableTouchReport = true
        
        // Value Format
        glucGraph.formatStringForValues = "%.1f"
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        if n_values == 0 {
            // 3 hrs
            return 5
        }
        else if n_values == 1 {
            // 6 hrs
            return 11
        }
        else if n_values == 2 {
            // 12 hrs
            return 23
        }
        else if n_values == 3 {
            // 24 hrs
            return 47
        }
        else {
            return 0
        }
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        if graph == glucGraph {
            if n_values == 0 {
                // 3 hrs
                return 3 * 60 / 5
            }
            else if n_values == 1 {
                // 6 hrs
                return 6 * 60 / 5
            }
            else if n_values == 2 {
                // 12 hrs
                return 12 * 60 / 5
            }
            else if n_values == 3 {
                // 24 hrs
                return 24 * 60 / 5
            }
            return glucoseLevels.count
        }
        else {
            return 0
        }
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        if graph == glucGraph{
            if n_values == 0 {
                // 3 hrs
                return "-\(175 - index*5)"
            }
            else if n_values == 1 {
                // 6 hrs
                return "-\(355 - index*5)"
            }
            else if n_values == 2 {
                // 12 hrs
                return "-\(715 - index*5)"
            }
            else if n_values == 3 {
                // 24 hrs
                return "-\(1435 - index*5)"
            }
        }
        return ""
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        if graph == glucGraph {
            if n_values == 0 {
                // 3 hrs
                return CGFloat(glucoseLevels.objectAtIndex(index + 251) as! NSNumber)
            }
            else if n_values == 1 {
                // 6 hrs
                return CGFloat(glucoseLevels.objectAtIndex(index + 215) as! NSNumber)
            }
            else if n_values == 2 {
                // 12 hrs
                return CGFloat(glucoseLevels.objectAtIndex(index + 143) as! NSNumber)
            }
            else if n_values == 3 {
                // 24 hrs
                return CGFloat(glucoseLevels.objectAtIndex(index) as! NSNumber)
            }
            return CGFloat(glucoseLevels.objectAtIndex(index) as! NSNumber)
        }
        else {
            return 0
        }
    }
    /*******************************
    *** Glucose and Insuline Levels
    ********************************/
    
    func setupGI() {
        // Amount of 5 minute intervals in a day
        var capacity = 24 * 60 / 5
        
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
    
    /*********************
    *** Timers
    *********************/

    func setupTimers() {
        
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refreshValues"), userInfo: nil, repeats: true)
        }
        
        graphRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refreshGraph"), userInfo: nil, repeats: true)
    }
    
    // Gets new values from BT or WiFi
    func refreshValues() {
        if sim {
            var gluc:Float = Float(Int(arc4random_uniform(10)) + 3)
            var insu:Float = Float(arc4random_uniform(10))/10.00
            
            glucoseLevels.removeObjectAtIndex(0)
            insulinLevels.removeObjectAtIndex(0)
            
            glucoseLevels.addObject(gluc)
            insulinLevels.addObject(insu)
        }
        
        if wifi {
            
            // API URL
            var api = "https://ic-yoda.appspot.com/_ah/api/icYodaApi/v1/glucInsuValues"
        
            // Request
            var request = NSMutableURLRequest(URL: NSURL(string: api)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            // Set request parameters
            var params = [String:String]()
//            params["n"] = "\((n_values+1) * 3 * 12)"
            params["n"] = "3"
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // Send Request
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                var err: NSError?
                
                // if no data
                if data == nil {
                    println("ERROR")
                    return
                }
                
                // Create JSON object
                var json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves, error: &err) as? NSDictionary
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                    
                    // WiFi not available
                    
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the values
                        var items = parseJSON["items"] as! NSArray
                        //                    println("Items: \(items)")
                        println("JSON from WIFI")
                        dispatch_async(dispatch_get_main_queue()) {
                            for item in items {
                                var date = item["date"] as! String
                                if  date > startDateTime && date > lastValueDate {
                                    let gluc = (item["gluc"] as! NSString).floatValue
                                    glucoseLevels.removeObjectAtIndex(0)
                                    glucoseLevels.addObject(gluc)
                                    
                                    let insu = (item["insu"] as! NSString).floatValue
                                    insulinLevels.removeObjectAtIndex(0)
                                    insulinLevels.addObject(insu)
                                    
                                    lastValueDate = date
                                }
                            }
                        }
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("Error could not parse JSON: \(jsonStr)")
                    }
                }
            })
            
            task.resume()
        }
    }
    
    func refreshGraph() {
        glucGraph.reloadGraph()
        
        refreshLabels()
    }
    func refreshLabels() {
        let gluc = glucoseLevels.lastObject as! Float
        let insu = insulinLevels.lastObject as! Float
        
        glucLabel.text = "\(gluc)"
        insuLabel.text = "\(insu)"
        
        //hypo
        if gluc <= 3 {
            yodaPicture.image = UIImage(named: "hypo_yoda.png")
            yodaHealth.text = "Hypoglycaemia"
        }
        //hyper
        else if gluc >= 12 {
            yodaPicture.image = UIImage(named: "hyper_yoda.png")
            yodaHealth.text = "Hyperglycaemia"
        }
        //healthy
        else {
            yodaPicture.image = UIImage(named: "yoda.png")
            yodaHealth.text = "Healthy"
        }
    }
    
    /******************************
    *** Bluetooth Peripheral
    ******************************/
    func connectBT() {
        
        if state == .IDLE {
            state = .SCANNING
            println("Started scan ...")
            centralManager.scanForPeripheralsWithServices([UARTPeripheral.uartServiceUUID()], options:[CBCentralManagerScanOptionAllowDuplicatesKey: false as NSNumber])
        }
        else if state == .CONNECTED {
            println("Connected")
            connectBTTimer.invalidate()
        }
    }

    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if(central.state != CBCentralManagerState.PoweredOn){
            println("centralManager powered off")
            state = .IDLE
            return
        }
        
        println("centralManager powered on")
        connectBTTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("connectBT"), userInfo: nil, repeats: true)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Did discover peripheral \(peripheral.name)")
        
        centralManager.stopScan()
        
        currentPeripheral = UARTPeripheral(peripheral: peripheral, delegate: self)
        centralManager.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Did connect peripheral \(peripheral.name)")
        state = .CONNECTED
        
        if currentPeripheral.peripheral.isEqual(peripheral) {
            currentPeripheral.didConnect()
        }
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Did disconnect peripheral \(peripheral.name)")
        
        state = .IDLE
        connectBT()
        
        if currentPeripheral.peripheral.isEqual(peripheral) {
            currentPeripheral.didDisconnect()
        }
    }
    
    func didReceiveData(string: String!) {
        addTextToConsole(string, dataType: .RX)
        
        // split string into array
        var input = NSString(string: string).componentsSeparatedByString(",")
        
        // Connection Settings Switched
        if (input.count == 1){
            let connection = (input[0] as! NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            switch connection {
            case "bt":
                println("Switched to BT")
                bt = true
                wifi = false
            case "wifi":
                println("Switched to WIFI")
                bt = false
                wifi = true
            default:
                println("Unknown command '\(connection)'")
                
            }
            
            return
        }
        
        // Glucose and Insulin values
        if input.count == 2 {
            var glucose = input[0] as! NSString
            var insulin = input[1] as! NSString
            
            var components = NSString(string: "\(NSDate())").componentsSeparatedByString(" ")
            var datetime = "\(components[0])&\(components[1])"
            
            var output:NSDictionary = [
                "date":datetime,
                "gluc":glucose,
                "insu":insulin,
            ]
            
            inboxGI.addObject(output)
            
            return
        }
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
        
        var output:NSString = "[\(formatter.stringFromDate(NSDate()))] \(direction) \(string)"
        
        println(output)
    }
}

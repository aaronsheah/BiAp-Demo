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
var sim = false

// Connections
var wifi = true
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

var feedOnly = false

/*********************
*** ViewController
*********************/

class CenterViewController: UIViewController, BEMSimpleLineGraphDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate, CBCentralManagerDelegate, UARTPeripheralDelegate {
    // slide out
    var delegate: CenterViewControllerDelegate?
    @IBAction func puppiesTapped(sender: AnyObject) {
        print("toggleRightPanel")
        delegate?.toggleRightPanel?()
        
        if feedOnly {
            print("feedOnly YES")
            
            glucGraph.hidden = true
            insuGraph.hidden = true
            glucLabel.hidden = true
            insuLabel.hidden = true
            glucNameLabel.hidden = true
            insuNameLabel.hidden = true
            periodLabel.hidden = true
            
            yodaPicture.hidden = true
            yodaHealth.hidden = true
            
            bigYoda.hidden = false
            imperialLogo.hidden = false
        }
        else {
            print("feedOnly NO")
            
            glucGraph.hidden = false
            insuGraph.hidden = false
            glucLabel.hidden = false
            insuLabel.hidden = false
            glucNameLabel.hidden = false
            insuNameLabel.hidden = false
            periodLabel.hidden = false
            
            yodaPicture.hidden = false
            yodaHealth.hidden = false
            
            bigYoda.hidden = true
            imperialLogo.hidden = true
        }
    }
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var bigYoda: UIImageView!
    @IBOutlet weak var imperialLogo: UIImageView!
    
    @IBOutlet weak var yodaPicture: UIImageView!
    @IBOutlet weak var yodaHealth: UILabel!
    
    @IBOutlet weak var glucNameLabel: UILabel!
    @IBOutlet weak var insuNameLabel: UILabel!
    @IBOutlet weak var glucGraph: BEMSimpleLineGraphView!
    @IBOutlet weak var insuGraph: JBBarChartView!
    @IBOutlet weak var mealLibraryContainer: UIView!
    @IBOutlet weak var glucLabel: UILabel!
    @IBOutlet weak var insuLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    // Timers
    var timer = NSTimer()
    var graphRefreshTimer = NSTimer()
    var connectBTTimer = NSTimer()
    
    // Last N Values
    var n_values = 0
    var temp_n_values = 0
    
    // Pan Gesture to change N Values/Time Range
    var start_x:CGFloat = 0
    var message:UILabel = UILabel()
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBAction func panAction(sender: AnyObject) {
        let pg = sender as! UIPanGestureRecognizer
        
        // graphview
        let coordinates = sender.translationInView(glucGraph)
        
        let x:CGFloat = coordinates.x
        
        // Find initial N Value
        if pg.state == UIGestureRecognizerState.Began {
            temp_n_values = n_values
            print("1n \(n_values)")
        }
        
        /**********************************/
        // Preview Changed N Value
        let diff = (x - start_x)/320.00
        var increment = 0
        
        
        if diff < 0 {
            
            if diff > -0.5  {
                increment = -1
            }
            else if diff > -1 {
                increment = -2
            }
            else if diff > -1.5{
                increment = -3
            }
        }
        else if diff > 0 {
            if diff < 0.5 {
                increment = 1
            }
            else if diff < 1 {
                increment = 2
            }
            else if diff < 1.5 {
                increment = 3
            }
        }
        
        
        n_values = temp_n_values + increment
        if n_values > 3 {
            n_values = 3
        }
        else if n_values < 0 {
            n_values = 0
        }
        /**********************************/
        
        // Set Final N Value
        if pg.state == UIGestureRecognizerState.Ended {
            temp_n_values += increment
            if temp_n_values > 3 {
                n_values = 3
            }
            else if temp_n_values < 0 {
                n_values = 0
            }
            else {
                n_values = temp_n_values
            }
        }
        
        switch n_values {
        case 0:
            periodLabel.text = "3 Hours"
        case 1:
            periodLabel.text = "6 Hours"
        case 2:
            periodLabel.text = "12 Hours"
        case 3:
            periodLabel.text = "24 Hours"
        default:
            periodLabel.text = ""
        }
        
        if !graphRefreshTimer.valid {
            refreshGraph()
        }
        
    }
    
    // Double Tap Gesture to Play/Pause Graph
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
    @IBAction func doubleTapGesture(sender: UITapGestureRecognizer) {
        print("DoubleTap")
        
        // Play
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CenterViewController.refreshValues), userInfo: nil, repeats: true)
            
            graphRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CenterViewController.refreshGraph), userInfo: nil, repeats: true)
        }
            
        // Pause
        else {
            timer.invalidate()
            graphRefreshTimer.invalidate()
        }
    }
    
    // Bluetooth
    var centralManager:CBCentralManager!
    var inputBuffer:String = ""

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
        
        bigYoda.hidden = true
        imperialLogo.hidden = true
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
        
        let minGluc = BEMAverageLine()
        minGluc.yValue = 3
        minGluc.enableAverageLine = true
        minGluc.color = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 0.2)
        minGluc.dashPattern = [5]
        
        let maxGluc = BEMAverageLine()
        maxGluc.yValue = 10
        maxGluc.enableAverageLine = true
        maxGluc.color = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.2)
        maxGluc.dashPattern = [5]
        
        glucGraph.minRefLine = minGluc
        glucGraph.maxRefLine = maxGluc
        
        insuGraph.dataSource = self
        insuGraph.delegate = self
        
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
    
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        return 0
    }
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        if n_values == 0 {
            return 3 * 60/5
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
        return UInt(insulinLevels.count)
    }
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        if n_values == 0 {
            // 3 hrs
            return insulinLevels[Int(index + 251)] as! CGFloat
        }
        else if n_values == 1 {
            // 6 hrs
            return insulinLevels[Int(index + 215)] as! CGFloat
        }
        else if n_values == 2 {
            // 12 hrs
            return insulinLevels[Int(index + 143)] as! CGFloat
        }
        else if n_values == 3 {
            // 24 hrs
            return insulinLevels[Int(index)] as! CGFloat
        }
        return 0
    }
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return UIColor(red: 1, green: 128/255, blue: 0, alpha: 1)
    }
    
    /*******************************
    *** Glucose and Insuline Levels
    ********************************/
    
    func setupGI() {
        // Amount of 5 minute intervals in a day
        let capacity = 24 * 60 / 5
        
        // Initialise arrays
        if time.count == 0 {
            for x in 0...capacity-1 {
                time.addObject(capacity-x as Int)
            }
        }
        
        if glucoseLevels.count == 0 {
            for _ in 0...capacity-1 {
                glucoseLevels.addObject(0 as Float)
            }
        }
        
        if insulinLevels.count == 0 {
            for _ in 0...capacity-1 {
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
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CenterViewController.refreshValues), userInfo: nil, repeats: true)
        }
        
        graphRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CenterViewController.refreshGraph), userInfo: nil, repeats: true)
    }
    
    // Gets new values from BT or WiFi
    func refreshValues() {
        if sim {
            let gluc:Float = Float(Int(arc4random_uniform(10)) + 3)
            let insu:Float = Float(arc4random_uniform(10))/10.00
            
            glucoseLevels.removeObjectAtIndex(0)
            insulinLevels.removeObjectAtIndex(0)
            
            glucoseLevels.addObject(gluc)
            insulinLevels.addObject(insu)
        }
        
        if wifi {
            
            // API URL
            let api = "https://ic-yoda.appspot.com/_ah/api/icYodaApi/v1/glucInsuValues"
        
            // Request
            let request = NSMutableURLRequest(URL: NSURL(string: api)!)
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            // Set request parameters
            var params = [String:String]()
            params["n"] = "3"
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                request.HTTPBody = nil
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let taskData = session.dataTaskWithRequest(request, completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                
                if (data != nil) {
                    let result = NSString(data: data! , encoding: NSUTF8StringEncoding)
//                    print("\(result!)")
                    
                    // convert String to NSData
                    let jsonData: NSData = result!.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    // convert NSData to 'AnyObject'
                    do {
                        let parseJSON = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? NSDictionary
                        if let parseJSON = parseJSON {
                            // Okay, the parsedJSON is here, let's get the values
                            let items = parseJSON["items"] as! NSArray
//                            print("Items: \(items)")
                            print("JSON from WIFI")
                            dispatch_async(dispatch_get_main_queue()) {
                                for item in items {
                                    let date = item["date"] as! String
                                    if  date > startDateTime && date > lastValueDate {
                                        let gluc = (item["gluc"] as! NSString).floatValue
//                                        print(gluc,item["gluc"] as! NSString)
                                        glucoseLevels.removeObjectAtIndex(0)
                                        glucoseLevels.addObject(gluc)
                                        
                                        let insu = (item["insu"] as! NSString).floatValue
                                        insulinLevels.removeObjectAtIndex(0)
                                        insulinLevels.addObject(insu)
//                                        print(insu,item["insu"] as! NSString)
                                        lastValueDate = date
                                    }
                                }
                            }
//                            print(glucoseLevels)
//                            print(insulinLevels)
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                        }
                    } catch _ as NSError {
                        
                    }

                }
                else {   // we got an error
                    print("Error getting stores :\(error!.localizedDescription)")
                }
            })
            
            taskData.resume()
        }
        
        else if bt {
            print("JSON from BT")
            let inbox = NSArray(array: inboxGI)
            inboxGI.removeAllObjects()
            btDrawGraph(inbox)
            return

        }
    }
    func btDrawGraph(items:NSArray) {
        for item in items {
            let date = item["date"] as! String
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
    
    func refreshGraph() {
        
        let glucMax = CGFloat(glucGraph.calculateMaximumPointValue())
        
        insuGraph.maximumValue = glucMax
        insuGraph.reloadData()

        glucGraph.maxRefLine.enableAverageLine = (glucMax >= 9)
        glucGraph.reloadGraph()
        
        refreshLabels()
    }
    func refreshLabels() {
        let gluc = glucoseLevels.lastObject as! Float
        let insu = insulinLevels.lastObject as! Float
        
        glucLabel.text = "\(gluc)"
        glucLabel.text = NSString(format: "%.2f", gluc) as String
        insuLabel.text = "\(insu)"
        
        //hypo
        if gluc <= 3.9 {
            yodaPicture.image = UIImage(named: "hypo_yoda.png")
            yodaHealth.text = "Hypoglycemia"
        }
        //hyper
        else if gluc >= 10 {
            yodaPicture.image = UIImage(named: "hyper_yoda.png")
            yodaHealth.text = "Hyperglycemia"
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
            print("Started scan ...")
            centralManager.scanForPeripheralsWithServices([UARTPeripheral.uartServiceUUID()], options:[CBCentralManagerScanOptionAllowDuplicatesKey: false as NSNumber])
        }
        else if state == .CONNECTED {
            print("Connected")
            connectBTTimer.invalidate()
        }
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if(central.state != CBCentralManagerState.PoweredOn){
            print("centralManager powered off")
            state = .IDLE
            return
        }
        
        print("centralManager powered on")
        connectBTTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CenterViewController.connectBT), userInfo: nil, repeats: true)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Did discover peripheral \(peripheral.name)")
        
        centralManager.stopScan()
        
        currentPeripheral = UARTPeripheral(peripheral: peripheral, delegate: self)
        centralManager.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Did connect peripheral \(peripheral.name)")
        state = .CONNECTED
        
        if currentPeripheral.peripheral.isEqual(peripheral) {
            currentPeripheral.didConnect()
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Did disconnect peripheral \(peripheral.name)")
        
        state = .IDLE
        connectBT()
        
        if currentPeripheral.peripheral.isEqual(peripheral) {
            currentPeripheral.didDisconnect()
        }
    }
    
    func didReceiveData(string: String!) {
        for c in string.characters {
            if (c != "\n" || c != "\r") {
                inputBuffer += "\(c)"
            }
            else {
                parseData(inputBuffer)
                inputBuffer = ""
                
                addTextToConsole(inputBuffer, dataType: .RX)
            }
        }
        
    }
    
    func parseData(string:String) {
        // split string into array
        var input = NSString(string: string).componentsSeparatedByString(",")
        
        // Connection Settings Switched
        if (input.count == 1){
            let connection = (input[0] as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            switch connection {
            case "bt":
                print("Switched to BT")
                bt = true
                wifi = false
            case "wifi":
                print("Switched to WIFI")
                bt = false
                wifi = true
            default:
                print("Unknown command '\(connection)'")
                
            }
        }
        
        // Glucose and Insulin values
        else if input.count == 2 {
            var glucose = input[0] as NSString
            let insulin = input[1] as NSString
            
            //////////////////////////////////////////////////////////////////
            let upperlimitgluc = 1.5 * (glucoseLevels.lastObject as! Float)
            let lowerlimitgluc = 0.0 as Float
            
            if (glucose.floatValue) > upperlimitgluc {
                glucose = "\(glucoseLevels.lastObject as! Float)"
            }
            else if (glucose.floatValue) < lowerlimitgluc {
                glucose = "\(glucoseLevels.lastObject as! Float)"
            }
            //////////////////////////////////////////////////////////////////
            
            var components = NSString(string: "\(NSDate())").componentsSeparatedByString(" ")
            let datetime = "\(components[0])&\(components[1])"
            
            let output:NSDictionary = [
                "date":datetime,
                "gluc":glucose,
                "insu":insulin,
            ]
            
            inboxGI.addObject(output)
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
        
        let output:NSString = "[\(formatter.stringFromDate(NSDate()))] \(direction) \(string)"
        
        print(output)
    }
}

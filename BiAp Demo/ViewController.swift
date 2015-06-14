//
//  ViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 11/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BEMSimpleLineGraphDelegate{

    @IBOutlet weak var glucGraph: BEMSimpleLineGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        glucGraph.enableYAxisLabel = true
        glucGraph.autoScaleYAxis = true
        
        glucGraph.enableReferenceAxisFrame = true
        
        glucGraph.enableXAxisLabel = true
        glucGraph.animationGraphEntranceTime = 0.5
        glucGraph.enablePopUpReport = true
        glucGraph.enableTouchReport = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 10
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        return "\(index)"
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        return CGFloat(index * 100)
    }
}


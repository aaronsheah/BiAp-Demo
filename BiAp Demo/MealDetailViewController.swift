//
//  MealDetailViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 14/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit

class MealDetailViewController: UIViewController, BEMSimpleLineGraphDelegate {

//    @IBOutlet weak var glucProfileGraph: BEMSimpleLineGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        glucProfileGraph.enableYAxisLabel = false
//        glucProfileGraph.autoScaleYAxis = true
//        
//        glucProfileGraph.enableReferenceAxisFrame = true
//        
//        glucProfileGraph.enableXAxisLabel = true
//        glucProfileGraph.animationGraphEntranceTime = 0.5
//        glucProfileGraph.enablePopUpReport = true
//        glucProfileGraph.enableTouchReport = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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

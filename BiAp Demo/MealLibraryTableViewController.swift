//
//  MealLibraryTableViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 11/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit

class mealCell: UITableViewCell {
    // 1. text label
    @IBOutlet weak var nameLabel: UILabel!
    // 2. meal thumbnail
//    @IBOutlet weak var thumbnail: UIImageView!
}

class MealLibraryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return mealLibrary.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mealCell", forIndexPath: indexPath) as! mealCell

        let meal = mealLibrary[indexPath.row]
        // Configure the cell...
        
        cell.nameLabel!.text = "\(meal.name)"

        // Set Thumbnail as Background Image
        var imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
        imageView.image = meal.thumbnail
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        
        return cell
    }

//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 150
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
//    func imageByCroppingImage(image:UIImage, size:CGSize) -> UIImage {
//
//        var refWidth:Double = Double(CGImageGetWidth(image.CGImage))
//        var refHeight:Double = Double(CGImageGetHeight(image.CGImage))
//        
//        let width:Double = Double(size.width)
//        let height:Double = Double(size.height)
//        
//        var x:CGFloat = CGFloat((refWidth - width)/2.0)
//        var y:CGFloat = CGFloat((refHeight - height)/2.0)
//        
//        var cropRect:CGRect = CGRectMake(x, y, size.width, size.height);
////        var imageRef:CGImageRef = CGImageCreateWithImageInRect(image as! CGImage, cropRect)
//
//        var imageRef:CGImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
//        
//        
//        var cropped:UIImage = UIImage(CGImage: imageRef, scale: 0.0, orientation: image.imageOrientation)!
//        
//        
//        return cropped
//    }

}

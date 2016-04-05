//
//  MealLibraryTableViewController.swift
//  BiAp Demo
//
//  Created by Aaron Sheah on 11/06/2015.
//  Copyright (c) 2015 Aaron Sheah. All rights reserved.
//

import UIKit

class mealCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

var mealDetailViewController:MealDetailViewController? = nil

class MealLibraryTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return mealLibrary.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create a cell of type mealCell
        let cell = tableView.dequeueReusableCellWithIdentifier("mealCell", forIndexPath: indexPath) as! mealCell

        // Get the current meal to be displayed in table
        let meal = mealLibrary[indexPath.row]
        
        // Name Label
        cell.nameLabel!.text = "\(meal.name)"

        // Set Thumbnail as Background Image
        let imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
        imageView.image = meal.thumbnail
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        cell.backgroundView = UIView()
        cell.backgroundView!.addSubview(imageView)
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let meal = mealLibrary[indexPath!.row] as Meal //set to the selected meal
            
            let vc = segue.destinationViewController as? MealDetailViewController
            if vc != nil {
                vc!.meal = meal
            }
        }
    }

}

//
//  StudentListViewController.swift
//  Location
//
//  Created by Baris Can Vural on 3/23/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, UITableViewDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var receivedJSON = JSON([])
    var rowNumber = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return receivedJSON.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentListCell", forIndexPath: indexPath) as! UITableViewCell
        //cell.selectionStyle = .None //don't highlight when selected
        
        cell.textLabel?.text = self.receivedJSON[indexPath.row]["name"].description
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

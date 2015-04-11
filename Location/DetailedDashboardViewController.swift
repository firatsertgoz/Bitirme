//
//  DetailedDashboardViewController.swift
//  Location
//
//  Created by Baris Can Vural on 3/6/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class DetailedDashboardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var rowNumber = 0;
    let httpHelper = HTTPHelper()
    var courseId : Int!
    var json = JSON([])
    var jsonToBeSent = JSON([])
    var names : NSMutableArray = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lecture Sessions"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        get_attendees()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNumber
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomPrototypeCell = self.tableView.dequeueReusableCellWithIdentifier("DetailedDashboardCell") as! CustomPrototypeCell
        cell.selectionStyle = .None //don't highlight when selected
        cell.textLabel?.text = self.json[indexPath.row]["created_at"].description
        cell.nameLabel.text = self.names[indexPath.row] as! String
        return cell
    }
    
    func get_attendees() {
        
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_attendees_by_course_id?course_id=\(self.courseId)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        //httpRequest.HTTPBody = "{\"course_id\":\"\(self.courseId)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                self.json = JSON(data: data)
                println(self.json)
                self.rowNumber = self.getRowCount()
                self.tableView.reloadData()
            }
        })
    }
    
    func getRowCount() -> Int {
        var set:Set<String> = Set<String>()
        for(var i=0;i<self.json.count;i++){
           set.insert(self.json[i]["name"].stringValue)
        }
        
        for name in set {
            self.names.addObject(name)
        }
        
        return set.count
    }
}

class CustomPrototypeCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
}





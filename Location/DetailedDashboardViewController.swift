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
    
    var names : NSMutableArray = []
    
    var atendeesData : JSON?
    var graphDataOverall : JSON?
    var graphDataMonth : JSON?
    var graphDataWeek : JSON?
    
    var atendeesArr : [Dictionary<String, AnyObject>] = []
    var graphOverallArr : [Dictionary<String, AnyObject>] = []
    var graphMonthArr:[Dictionary<String, AnyObject>] = []
    var graphWeekArr : [Dictionary<String, AnyObject>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lecture Sessions"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        get_attendees()
        get_attendance_count_for_graph(1)
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
        cell.textLabel?.text = self.atendeesData![indexPath.row]["created_at"].stringValue
        cell.nameLabel.text = self.names[indexPath.row] as! String
        return cell
    }
    
    func get_attendance_count_for_graph(option:Int) {
        // HTTP Request
        let httpRequest = httpHelper.buildRequest(
            "get_attendance_count_for_graph?course_id=\(self.courseId)&option=\(option)",
            method: "GET",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                
                var receivedJSON = JSON(data:data)
                
                switch (option) {
                case (0):
                    self.graphDataOverall = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: self.graphOverallArr)
                case (1):
                    self.graphDataMonth = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: self.graphMonthArr)
                case (2):
                    self.graphDataWeek = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: self.graphWeekArr)
                default:
                    println("Option invalid")
                }
                println(receivedJSON)
                self.tableView.reloadData()
            }
        })
    }
    
    func drawGraph(){
        
        
        
        
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
                self.atendeesData = JSON(data: data)
                self.writeAtendeesJsonToArrOfDict(self.atendeesData!, arrDict: self.atendeesArr)
                println(self.atendeesData)
                self.rowNumber = self.getRowCount()
                self.tableView.reloadData()
            }
        })
    }
    
    func getRowCount() -> Int {
        var set:Set<String> = Set<String>()
        for(var i=0;i<self.atendeesData!.count;i++){
            set.insert(self.atendeesData![i]["name"].stringValue)
        }
        for name in set {
            self.names.addObject(name)
        }
        return set.count
    }
    
    func writeAtendeesJsonToArrOfDict(json:JSON, var arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["name":json[i]["name"].stringValue,
                         "attendance_date":json[i]["attendance_date"].stringValue,
                        "total_lectures" : json[i]["total_lectures"].stringValue
                ])
        }
    }
    func writeGraphJsonToArrOfDict(json:JSON, var arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["day":json[i]["day"].stringValue,
                "start_time":json[i]["start_time"].stringValue,
                "total_attendance_count" : json[i]["total_attendance_count"].stringValue
                ])
        }
    }
}

class CustomPrototypeCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
}





//
//  DetailedDashboardViewController.swift
//  Location
//
//  Created by Baris Can Vural on 3/6/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit
import Charts

class DetailedDashboardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ChartViewDelegate{
    
    var rowNumber = 0;
    let httpHelper = HTTPHelper()
    var courseId : Int!
    var GraphOption = 0
    
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
    @IBOutlet weak var graph: HorizontalBarChartView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Attendance"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        get_attendees()
        get_attendance_count_for_graph(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNumber
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:DetailedDashboardCell = self.tableView.dequeueReusableCellWithIdentifier("DetailedDashboardCell") as! DetailedDashboardCell
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
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphOverallArr)
                    self.sortArrayByDate(&self.graphOverallArr)
                   // self.drawGraph(0)
                case (1):
                    self.graphDataMonth = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphMonthArr)
                    self.sortArrayByDate(&self.graphMonthArr)
                case (2):
                    self.graphDataWeek = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphWeekArr)
                    self.sortArrayByDate(&self.graphWeekArr)
                default:
                    println("Option invalid")
                }
                println(receivedJSON)
                self.tableView.reloadData()
            }
        })
    }
    
    func drawGraph(option:Int){
        if(option==0){
            graph.delegate = self
            
        } else if(option==1){
            
        } else if(option==2){
            
        }
    }
    
//    func drawGraph(option:Int){
//        
//        if(option==0){
//          
//            var xValues:NSMutableArray = []
//            var yValues:NSMutableArray = []
//            for(var i = 0;i<self.graphOverallArr.count;i++){
//                var day = self.graphOverallArr[i]["day"] as! String
//                var time = substr((self.graphOverallArr[i]["start_time"] as! String),start: 11,end: 16)
//                var count: Int! = (self.graphOverallArr[i]["total_attendance_count"] as! String).toInt()
//                xValues.addObject((day+" "+time))
//    
//                yValues.addObject(count)
//                //self.graphOverallArr[i]["total_attendance_count"]
//            }
//            barChart.xLabels = xValues
//            barChart.yValues = yValues
//            let totalLectures: Int! = (self.atendeesArr[0]["total_lectures"] as! String).toInt()
//            barChart.yValueMax = intToCGFloat(totalLectures)
//        
//            barChart.strokeChart()
//        } else if (option==1){
//            
//            barChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
//            barChart.yValues = [1,24,12,18,30,10,21]
//            barChart.strokeChart()
//        } else {
//            
//            barChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
//            barChart.yValues = [1,24,12,18,30,10,21]
//            barChart.strokeChart()
//            
//        }
//        
//        
//        
//    }

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
                self.writeAtendeesJsonToArrOfDict(self.atendeesData!, arrDict: &self.atendeesArr)
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
    
    func writeAtendeesJsonToArrOfDict(json:JSON, inout arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["name":json[i]["name"].stringValue,
                         "attendance_date":json[i]["attendance_date"].stringValue,
                        "total_lectures" : json[i]["total_lectures"].stringValue
                ])
        }
    }
    func writeGraphJsonToArrOfDict(json:JSON, inout arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["day":json[i]["day"].stringValue,
                "start_time":json[i]["start_time"].stringValue,
                "total_attendance_count" : json[i]["total_attendance_count"].stringValue
                ])
        }
    }
    
    func sortArrayByDate(inout arrDict: [Dictionary<String, AnyObject>]) {
        
       
        var x, y : Int
        var key : Dictionary<String,AnyObject>
        
        for (x = 0; x < arrDict.count; x++) { //obtain a key to be evaluated
            key = arrDict[x]
            //iterate backwards through the sorted portion 
            for (y = x; y > -1; y--) {
                if (compareDicts(&key,dic2:&arrDict[y])==0) {
                    //remove item from original position
                    arrDict.removeAtIndex(y + 1)
                    //insert the number at the key position
                    arrDict.insert(key, atIndex: y)
                }
            } //end for
        }
    }
    
    // a < b returns 0
    // a = b returns 1
    // a > b returns 2
    
    func compareDicts(inout dic1: Dictionary<String, AnyObject>, inout dic2: Dictionary<String,AnyObject>) -> Int {
        
        var days = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
        var day1 = findInArr(days,str: dic1["day"] as! String)
        var day2 = findInArr(days,str: dic2["day"] as! String)
        
        if(  day1 < day2) {
            return 0
        } else if (day1==day2){
            var time1 = (dic1["start_time"] as! String).substr(11,end: 16)
            var time2 = (dic2["start_time"] as! String).substr(11,end: 16)
            if( time1 < time2 ){
                return 0
            } else if (time1==time2){
                return 1
            } else { //time1 > time2
                return 2
            }
        } else { //day1 > day2
            return 2
        }
    }
    
    func findInArr(arr : Array<String>,str:String) -> Int {
        var count = 0
        for(var i = 0;  i<arr.count; i++ ){
            if(arr[i]==str){
                return count
            }
            count++
        }
        return -1
    }
    
    func intToCGFloat(value:Int) -> CGFloat {
        let f : CGFloat = CGFloat(value)
        return f
    }
    
    
    
}

class DetailedDashboardCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
}





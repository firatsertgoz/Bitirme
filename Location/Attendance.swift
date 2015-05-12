//
//  Attendance.swift
//  Location
//
//  Created by Baris Can Vural on 4/20/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import Foundation


class Attendance {
    
    //static var count : Int = 0
    static let json = JSON(NSUserDefaults.standardUserDefaults().objectForKey("Schedule") as! NSArray)
    static var counter = 0
    class func registerBeaconInfo(location:String,count:Int){
        var parameter = count
        for (var i=0;i<json.count;i++){
            var courseLoc = json[i]["location"].stringValue
            if( json[i]["day"].stringValue == NSDate.getCurrentDay() &&
                courseLoc == location) {
                    let startTime = json[i]["start_time"].stringValue.getTimeFromDateString()
                    let endTime = json[i]["end_time"].stringValue.getTimeFromDateString()
                    let d = NSDate.getCurrentTime()
                    if (d>startTime && d<=endTime){
                        println("count: \(counter)")
                        counter++
                        if(counter==parameter*(numOfHours(startTime, time2: endTime))){
                            counter = 0
                            makeAttendanceRequest(json[i]["id"].int!)
                        }
                    }
            }
        }
    }
    
    private class func numOfHours(time1:String,time2:String) -> Int {
        let hour1 : Int! = time1.componentsSeparatedByString(":").first?.toInt()
        let hour2 : Int! = time1.componentsSeparatedByString(":").first?.toInt()
        return hour2-hour1
    }
    
    private class func makeAttendanceRequest(ceId:Int){
        var httpHelper = HTTPHelper()
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("attend", method: "POST", authType: HTTPRequestAuthType.HTTPTokenAuth)
        httpRequest.HTTPBody = "{\"course_entity_id\":\"\(ceId)\"\"}".dataUsingEncoding(NSUTF8StringEncoding)
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = httpHelper.getErrorMessage(error)
            }
            else {
                var jsonerror:NSError?
                var response = JSON(data: data)
                println("Attendance response")
                println(response)
            }
        })
    }
}





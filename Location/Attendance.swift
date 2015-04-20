//
//  Attendance.swift
//  Location
//
//  Created by Baris Can Vural on 4/20/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import Foundation


class Attendance {
    
    
    static var count : Int = 0
    static let json = JSON(NSUserDefaults.standardUserDefaults().objectForKey("Schedule") as! NSArray)
    
    
    class func registerBeaconInfo(location:String){
        
        for (var i=0;i<json.count;i++){
            var courseLoc = json[i]["location"].stringValue
            if(courseLoc == location) {
                let startTime = json[i]["start_time"].stringValue
                let endTime = json[i]["end_time"].stringValue
                let d = NSDate.getCurrentTime()
                if(d>startTime && d<=endTime){
                    count++
                    if(count==4){
                        count = 0
                        makeAttendanceRequest(json[i]["id"].int!)
                    }
                    
                    
                }
                
            }
                
            }
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
    
    
    

    
    
    

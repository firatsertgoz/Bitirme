//
//  DashboardViewController.swift
//  Location
//
//  Created by Baris Can Vural on 3/6/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController,UITableViewDelegate {

    var rowNumber = 0;
    var receivedJSON = JSON([])
    let httpHelper = HTTPHelper()
    var json = JSON([])
    
    
    @IBAction func createPressed(sender: AnyObject) {
        println("Create pressed")
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        println(self.receivedJSON)
        tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "InstructorCell")
        getCourses()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowNumber
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell = UITableView(style: UITableViewCellStyle.Default, reuseIdentifier: "InstructorCell") as CustomTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("InstructorCell", forIndexPath: indexPath) as CustomTableViewCell
        cell.selectionStyle = .None //don't highlight when selected
        cell.textLabel?.text = self.json[indexPath.row]["name"].description
        return cell
    }
    
    func getCourses(){
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_courses", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                var jsonerror:NSError?
                self.json = JSON(data: data)
                self.rowNumber = self.json.count
                println(self.json)
                self.tableView.reloadData()
            }
        })
    }
    
     func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Create a Lecture Session", handler:{action, indexpath in
            println("MORE•ACTION");
            self.createLectureSession(self.json[indexPath.row]["id"].int!)
            
        });
        
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        return [ moreRowAction];
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    }
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        // hide activityIndicator view and display alert message
        //self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    func createLectureSession(courseId:Int) {
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("create_lecturesession_by_course_id", method: "POST",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        
        httpRequest.HTTPBody = "{\"course_id\":\"\(courseId)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                return
            }
            
            // hide activity indicator and update userLoggedInFlag
            // self.activityIndicatorView.hidden = true
            // self.updateUserLoggedInFlag()
            
            var jsonerror:NSError?
            let responseDict = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as NSDictionary
            var stopBool : Bool
            
            // save API AuthToken and ExpiryDate in Keychain
//            self.saveApiTokenInKeychain(responseDict)
//            self.jsonData = JSON(data:data) //save json to pass it to the next controller
            var jsonReturned = JSON(data:data)
            println(jsonReturned)
            
        })
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

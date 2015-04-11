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
    var selectedCourseId : Int?
    
    // Disable navigation bar
    override func viewWillAppear(animated:Bool){
    super.viewWillAppear(animated);
        self.navigationItem.setHidesBackButton(true,animated:false)   //it hides
        self.navigationItem.title = "Dashboard"
    }
    
    @IBAction func createPressed(sender: AnyObject) {
        println("Create pressed")
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        println(self.receivedJSON)
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
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "InstructorCell") as UITableViewCell
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
        let errorAlert = UIAlertView(title:alertTitle as String, message:alertDescription as String, delegate:nil, cancelButtonTitle:"OK")
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
            
            var jsonerror:NSError?
            let responseDict = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
            var stopBool : Bool

            var jsonReturned = JSON(data:data)
            println(jsonReturned)
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let targetView = self.storyboard?.instantiateViewControllerWithIdentifier("DetailedDashboard") as! DetailedDashboardViewController
        self.selectedCourseId = self.json[indexPath.row]["id"].int!
        println("Json is:\n \(self.json.string)")
        println("selectedCourseId is \(self.selectedCourseId)")
        
        let customNav = self.navigationController as! CustomNavigationController
        customNav.DashboardViewController_selectedCourseId = self.selectedCourseId
        self.navigationController?.performSegueWithIdentifier("DashboardToDetailed", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "DashboardToDetailed") {
            let navController = segue.destinationViewController as! UINavigationController
            let destinationView = navController.topViewController as! DetailedDashboardViewController
         //   let destinationView = segue.destinationViewController as DetailedDashboardViewController
            destinationView.courseId = self.selectedCourseId!
        }
    }
}

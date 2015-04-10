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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lecture Sessions"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getLectureSessions()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailedDashboardCell", forIndexPath: indexPath) as! UITableViewCell
        
        //cell.selectionStyle = .None //don't highlight when selected
        cell.textLabel?.text = self.json[indexPath.row]["created_at"].description
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let ls_id = self.json[indexPath.row]["id"].int
        
        getStudentListForNextView(ls_id!)
        
        
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "DetailedDashboardToStudentList" {
           let destinationView =  segue.destinationViewController as! StudentListViewController
            destinationView.receivedJSON = self.jsonToBeSent
        }
    }
    
    func getStudentListForNextView(lecture_session_id:Int){
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_student_list_by_lecture_session_id?lecture_session_id=\(lecture_session_id)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                var jsonerror:NSError?
                self.jsonToBeSent = JSON(data: data)
                self.performSegueWithIdentifier("DetailedDashboardToStudentList", sender: self)
            }
        })
    }
    
    func getLectureSessions(){
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_lecture_sessions_by_course_id?course_id=\(self.courseId)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
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

}

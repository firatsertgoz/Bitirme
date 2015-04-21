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
    var termStartDate : String?
    
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
        cell.textLabel?.text = self.json[indexPath.row]["course"]["name"].stringValue
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let targetView = self.storyboard?.instantiateViewControllerWithIdentifier("DetailedDashboard") as! DetailedDashboardViewController
        self.selectedCourseId = self.json[indexPath.row]["course"]["id"].int!
        println("Json is:\n \(self.json.string)")
        println("selectedCourseId is \(self.selectedCourseId)")
        
        let customNav = self.navigationController as! CustomNavigationController
        customNav.DashboardViewController_selectedCourseId = self.selectedCourseId
        self.navigationController?.performSegueWithIdentifier("DashboardToDetailed", sender: self)
    }
}

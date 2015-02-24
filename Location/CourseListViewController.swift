//
//  CourseListViewController.swift
//  Location
//
//  Created by Firat Sertgoz on 24/02/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class CourseListViewController: UIViewController, UITableViewDelegate {

   

    var rowNumber = 0
    var json:JSON = []
    var responseDict:NSArray = NSArray()
    @IBOutlet weak var tableView: UITableView!
   // var responseDict:NSDictionary = NSDictionary()

    let httpHelper = HTTPHelper()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCourses()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowNumber
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = self.json[indexPath.row]["name"].description
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
                println(self.json[0]["id"])
                self.rowNumber = self.json.count
               self.updateTableView()
            }
        })
    }
    func updateTableView()
    {
        self.tableView.reloadData()
    }
}



import UIKit

class DetailedCourseListViewController: UIViewController,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
   
    let httpHelper = HTTPHelper();
    var json = JSON([]);
    var courseId : Int!;
    var rowCount = 0;
    var dataArray : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAttendedSessionsByCourseId(self.courseId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        // Configure the cell...
        let cell = tableView?.dequeueReusableCellWithIdentifier("DetailedCourseListRow", forIndexPath: indexPath!) as! UITableViewCell
        cell.textLabel!.text = self.dataArray[indexPath!.row] as? String
        return cell
    }
    
    func getAttendedSessionsByCourseId(courseId:Int){
        
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_attended_sessions_by_course_id?course_id=\(self.courseId)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        println("Inside getAttendedSessions... courseId:\(courseId)")
        println("{\"course_id\":\"\(courseId)\"}")
        //httpRequest.HTTPBody = "{\"course_id\":\"\(self.courseId)\"}".dataUsingEncoding(NSUTF8StringEncoding)
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
                //   println(self.json[0]["id"])
                //    self.rowNumber = self.json.count
                println(self.json[0].string)
                self.updateTableView()
            }
        })
    }

    func updateTableView(){
        self.tableView.reloadData()
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

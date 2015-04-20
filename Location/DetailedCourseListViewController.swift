
import UIKit

class DetailedCourseListViewController: UIViewController,UITableViewDelegate {

    @IBOutlet weak var totalAttendanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weeksLabel: UILabel!
    
    let httpHelper = HTTPHelper();
    var json = JSON([]);
    var courseId : Int!;
    var rowCount = 0;
    var dataArray : NSArray = NSArray()
    var termStartDate : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAttendedSessionsByCourseId(self.courseId)
        
        var startDate: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("TermStartDate")
        if (startDate==nil){
            get_term_start_date()
        } else {
            println(startDate as! NSDictionary)
            self.termStartDate = JSON(startDate as! NSDictionary)["termstartdate"].stringValue
            updateWeeksLabel()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "DetailedCourseListRow")
        cell.selectionStyle = .None
       // cell.textLabel?.text = self.json[indexPath!.row][1].description
        var str : String = self.json[indexPath!.row]["created_at"].stringValue
        var newString = str.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newString = newString.substr(0,end:16)
        cell.textLabel?.text = newString
        return cell
    }
    func get_term_start_date(){
        
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_term_start_date", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
    
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
                var json = JSON(data:data)
                NSUserDefaults.standardUserDefaults().setObject(json.object, forKey: "TermStartDate")
                self.termStartDate = json["termstartdate"].stringValue
                self.updateWeeksLabel()
            }
        })
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
                self.json = JSON(data: data)
                println(self.json)
                self.rowCount = self.json.count
                self.updateTableView()
            }
        })
    }
    func updateWeeksLabel(){
         //self.weeksLabel.text = String(stringInterpolationSegment: self.termStartDate)
        var date = NSDate(dateString: self.termStartDate);
        var secondsNS: NSTimeInterval = date.timeIntervalSinceNow
        var seconds:Int = Int(secondsNS)
        var weeks = ((-1) * (seconds) ) / (60*60*24*7)
        self.weeksLabel.text = "Week \(String(weeks))"
    }
    
    func updateTableView(){
        self.tableView.reloadData()
        self.totalAttendanceLabel.text = "Total Attendances: \(self.rowCount)"
    }
}

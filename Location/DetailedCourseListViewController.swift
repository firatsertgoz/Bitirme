
import UIKit
import Charts

class DetailedCourseListViewController: UIViewController,UITableViewDelegate, ChartViewDelegate {

    @IBOutlet weak var totalAttendanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weeksLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    
    let httpHelper = HTTPHelper();
    var json = JSON([]);
    var courseId : Int!;
    var rowCount = 0;
    var dataArray : NSArray = NSArray()
    var termStartDate : String!
    var percentage : Int? //selected percentage
    var courseName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAttendedSessionsByCourseId(self.courseId)
        tableView.separatorInset.right = tableView.separatorInset.left
        
        
        var startDate: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("TermStartDate")
        if (startDate==nil){
            get_term_start_date()
        } else {
            println(startDate as! NSDictionary)
            self.termStartDate = JSON(startDate as! NSDictionary)["termstartdate"].stringValue
            updateWeeksLabel()
        }
        setPieChartOptions(pieChart, centerText: "\(percentage!)")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = self.courseName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        var cell:CustomDetailedCourseListCell = self.tableView.dequeueReusableCellWithIdentifier("DetailedCourseListRow") as! CustomDetailedCourseListCell
        cell.selectionStyle = .None
        var str : String = self.json[indexPath!.row]["created_at"].stringValue
        var newString = str.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newString = newString.substr(0,end:16)
        cell.dateLabel.text = newString.substr(0, end: 10)
        cell.timeLabel.text = newString.substr(11, end: 16)
       
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
    func setPieChartOptions(pie:PieChartView,centerText:String){
        
        pie.delegate = self
        pie.usePercentValuesEnabled = true
        pie.holeTransparent = true
        pie.holeRadiusPercent = 0.97
        pie.transparentCircleRadiusPercent = 0.55
        pie.drawHoleEnabled = true
        pie.descriptionText = ""
        pie.rotationAngle = 0
        pie.rotationEnabled = true
        pie.userInteractionEnabled = false
        pie.animate(xAxisDuration: 1.5,yAxisDuration:1.5)
        
        var colors :NSMutableArray = NSMutableArray()
        colors.addObjectsFromArray(ChartColorTemplates.colorful())
        colors.addObjectsFromArray(ChartColorTemplates.joyful())
        
        var color :UIColor = UIColor(red: 255/255 , green: 3/255, blue: 3/255, alpha: 1)
        var color2:UIColor = UIColor(red: 206/255 , green: 216/255, blue: 222/255, alpha: 1)
        var c = [color,color2]
        
        pie.centerText = "%"+centerText
        
        var entry : BarChartDataEntry = BarChartDataEntry(value: centerText.floatValue, xIndex: 0)
        
        var complement : BarChartDataEntry = BarChartDataEntry(value:100 - centerText.floatValue, xIndex:1)
        var yValues = [entry,complement]
        
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yValues)
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        pie.legend.enabled = false
        var data : ChartData = ChartData(xVals: ["",""], dataSet: dataSet)
        dataSet.colors = c
        pie.data = data
        
    }
}

class CustomDetailedCourseListCell : UITableViewCell{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

